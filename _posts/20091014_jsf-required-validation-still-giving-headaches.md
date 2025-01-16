# JSF Required Validation Still Giving Headaches...
For some time ago, we had decided not to use `JSF`’s `required` attribute and instead handle required validation with a 
`validator` object implementing `Validator` interface, attached to the current `UIInput` component. By that way, we were 
able to develop validation bypass mechanism while being able to update the `model`, and group validation capability which 
let us group components in the same `UIForm` and trigger their `validators` separately. My 
[ex-teammate](http://www.jroller.com/hasant/) has actually created 
an [open source project](http://code.google.com/p/commons-validator-ext/source/browse/trunk/main/src/com/cvext/requiredvalidation/controls/ui/RequiredValidatorChecker.java) 
and made those works public, so that other poor `JSF` developers having nightmares with `JSF`’s 
silliness could benefit from them.

Actually, our work has been working without any problem till I recently decided to develop a bulk update mechanism with 
an editable `datatable` component. When I placed some `UIInput` components to display column values and at the same time 
let users edit those column values, somehow required validation errors started to show off on my screen, although 
non-empty/non-null values for those components were being submitted with the current request.

After a quick investigation I realized that `UIData` is handling `decode`, `validation`, `update model` phases differently 
than other `UIInput` components on the same page. Shortly speaking, `UIData` component iterates over each row and calls 
`processDecodes`, `processValidators` and `processUpdates` methods of each and every child `UIComponent`. Components 
`submittedValues` are set during those calls, but at the end they are reset again. In other words, those child components 
will have their `localValue` and `submittedValue` properties set only during `processXXX` method calls of their ancestor 
`UIData` component.

On the other hand, our [required validation fix](http://code.google.com/p/commons-validator-ext/source/browse/trunk/main/src/com/cvext/requiredvalidation/controls/ui/RequiredValidatorChecker.java) 
was working as follows. First it starts from `UIForm` or `UIViewRoot` and 
traverses the whole component tree and tries to find components with `EditableValueHolder` interface. When a component 
is found with that type, its registered `validator` objects are checked if one for required validation is available. If 
it is, then that required `validator` is called either with `localValue` or `submittedValue` of that component. 
Unfortunately, `EditableValueHolder` components with a `UIData` ancestor will contain none of them as explained above. 
As a result, required validation fails while not-null/not-empty component values exist in the current request.

It looked that our fix was limited to components outside `UIData` components. After a deep thought, I decided to return 
back to use of `JSF`’s `required` attribute. There was no other way around. However, I needed a way to keep those bypass 
and group validation capabilities available in our project. My solution is simply based on disabling and enabling `required` 
attributes of those components during `processDecodes`, `processValidators` method calls. First part traverses the whole 
component tree and calls `setRequired(false)` of components in case validation is bypassed or the current component 
hasn’t a `validator` with `groupId` equals to active validation group id submitted. After that `processXXX` methods are 
executed. If any component left with `required=true`, its value will be checked by `JSF`. If validations are asked to be 
bypassed, or current active validation group id is different than registered `validators`’s `groupId` attributes, then 
those components’ `required` checks won't happen. At the end, second part of the solution starts executing. It again 
traverses the whole component tree and restores original `required` attribute values of those components.

In summary, I am able to keep available bypass and group validation capabilities, while having components inside `UIData` 
validated correctly. On the other hand, I again exposed to `JSF` specification’s bad design choices again. I don’t know 
if the expert team had considered required validation to be handled the same as other `validators`, but if they had so, 
`JSF`’s validation framework would have been much more consistent, and would be giving more options to customize the 
mechanism similar to our ones.
