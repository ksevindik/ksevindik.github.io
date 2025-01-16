# Customizing JSF Required Field Messages per Component Instance
JSF is advantageous in that it provides several useful built-in features for validating entered values or ensuring that 
required values are provided. However, it falls short in providing sufficient mechanisms for developers to customize 
these features at the level of each component instance. This is a common drawback of the JSF specification in general.

We specify that user input is required for an input text, textarea, or select listbox by setting its required field to 
true. During the validation phase, JSF checks if any user input has been entered for the component. If the user has not 
provided any input for the component, it becomes invalid, and an unattractive error message is raised via 
FacesContext.addMessage(), stating something like "Input required for this field...". There is no way to customize that 
error message except by localizing it in your preferred language, specific to each component instance. For example, it 
would be beneficial to have a message for a component that gathers username information, stating "You must provide valid 
username information here...".

Rick Hightower has addressed this issue in a blog seeking solutions. Unfortunately, there is no proper way to customize 
required messages without resorting to hacking methods. Rick employs a PhaseListener that comes into play after the 
validation phase. It searches for Faces messages, looking for any matches with the default Faces required error message 
text. When it finds one, it strips off the clientId of the component, then searches for a better message from the message 
bundle with the clientId key. Finally, default summary and detail message texts are replaced with custom ones.

We have implemented a similar hack in our project. A major deviation from Rick’s solution is that we perform the required 
field validation ourselves before the validation phase. We also employ a message key to indicate a custom required message 
in the bundle with f:attribute within components whose required messages we want to customize. Our PhaseListener traverses 
the entire UIComponent tree and identifies which UIInput components have required fields with a value of true. It then 
checks if the user has provided any input. If input is not provided, the component is marked as invalid, and a Faces 
error message is created. It first searches for custom required error message text, and if it finds one, it creates a 
Faces error message with custom error message text specific to that UIComponent/UIInput instance. If it does not find 
any custom message text key, it then uses the default Faces required message text. Below is its source code.
```java
import java.util.Iterator;
import java.util.Locale;
import java.util.ResourceBundle;
import javax.faces.application.FacesMessage;
import javax.faces.component.UIComponent;
import javax.faces.component.UIInput;
import javax.faces.component.UIViewRoot;
import javax.faces.context.FacesContext;
import javax.faces.event.PhaseEvent;
import javax.faces.event.PhaseId;
import javax.faces.event.PhaseListener;
import org.apache.commons.lang.StringUtils;

public class RequiredFieldValidatorPhaseListener implements PhaseListener {
    private final static String REQUIRED_FIELD_ATTRIBUTE_KEY = "requiredMsgKey";

    private ResourceBundle resourceBundle;

    public void afterPhase(PhaseEvent event) {    }

    public void beforePhase(PhaseEvent event) {
        FacesContext facesContext = event.getFacesContext();
        UIViewRoot viewRoot = facesContext.getViewRoot();
        initializeResourceBundle(facesContext);
        doCustomRequiredFieldValidation(facesContext,viewRoot);
    }

    public PhaseId getPhaseId() {
        return PhaseId.PROCESS_VALIDATIONS;
    }

    private void initializeResourceBundle(FacesContext facesContext) {
        String messageBundle = facesContext.getApplication().getMessageBundle();
        Locale locale = facesContext.getApplication().getDefaultLocale();
        resourceBundle = ResourceBundle.getBundle(messageBundle,locale);
    }

    private void doCustomRequiredFieldValidation(FacesContext facesContext, UIComponent component) {

        if(component instanceof UIInput) {
            UIInput inputComponent = (UIInput)component;
            if(inputComponent.isRequired()) {
               boolean valid = validateValue(inputComponent);

               if(!valid){
                   inputComponent.setValid(false);
                   addErrorMessage(facesContext,inputComponent);
                   facesContext.renderResponse();
               }
            }
        }  

       
        for (Iterator iter = component.getChildren().iterator(); iter.hasNext();) {
            UIComponent childComponent = (UIComponent) iter.next();
            doCustomRequiredFieldValidation(facesContext,childComponent);
        }
    }

    private String getRequiredFieldMsgKey(UIInput inputComponent) {
        String msgKey = (String)inputComponent.getAttributes().get(REQUIRED_FIELD_ATTRIBUTE_KEY);
        return msgKey;
    }

    private boolean  validateValue(UIInput inputComponent) {
        boolean valid = true;

        Object submittedValue = inputComponent.getSubmittedValue();

        if(submittedValue == null) {
            valid = false;
        } else if(submittedValue instanceof String) {
            valid = !StringUtils.isEmpty((String)submittedValue);
        }
        return valid;
    }

    private void addErrorMessage(FacesContext facesContext, UIInput component) {
        String msgKey = getRequiredFieldMsgKey(component);

        String summary = getValue("summary." + msgKey);

        if(summary == null) {

            summary = resourceBundle.getString("javax.faces.component.UIInput.REQUIRED");
        }

        String detail  = getValue("detail." + msgKey);

        FacesMessage facesMessage = new FacesMessage(FacesMessage.SEVERITY_FATAL,summary,detail);
        facesContext.addMessage(component.getClientId(facesContext),facesMessage);
    }

    private String getValue(String key) {
        try {
            return resourceBundle.getString(key);
        } catch (RuntimeException e) {
            return null;
        }
    }
}
```
Finally, let's take a look inside a JSF page and see how it is employed for UIInput type components.
```xml
<h:inputText id="txtName" required="true" >
            <f:attribute name="requiredMsgKey" value="msgNameRequired" />
</h:inputText>
```