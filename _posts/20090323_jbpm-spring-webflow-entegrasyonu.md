# JBPM Spring WebFlow Entegrasyonu

JBPM ile Business Process Management kabiliyetinin mevcut mimarimize dahil edilmesindeki ikinci adım `Spring WebFlow` 
entegrasyonu oldu. Bu noktada daha fazla devam etmeden evvel, önceki yazımda bahsettiğim JPA kullanan uygulamalarımızın 
JBPM ile aynı transaction context içerisinde çalıştırılması, bu ve diğer yazılarımda üzerinde duracağım 
`JBPM – Spring WebFlow` entegrasyonu konularında çalışma arkadaşım [İlker Çelik](icelik@gmail.com)’in çok büyük katkısı 
olduğunu belirtmek isterim.

`SWF` kullanıcı senaryolarını `flow`’lar olarak tasarlayıp implement etmek için çok güzel bir ortam sunmaktadır. `JBPM` 
ile de bir iş akışı baştan sona modellenerek execute edilmektedir. `JBPM`’de iş akışının her bir adımında belirli 
`task`’ların kullanıcı veya dış servisler tarafından yürütülmesi gerekmektedir. `JBPM` genel olarak bir iş akışını 
yönetmeye odaklanırken, `SWF` ise bu iş akışındaki her bir `task`’ın yürütülmesine odaklanmaktadır. Yani `JBPM` makro 
düzeyede çalışırken, `SWF` ise mikro düzeyde kalmaktadır.

İş akışındaki her bir `task` `SWF`’de bir `flow`’a karşılık gelmektedir. Bunun yanı sıra `SWF` tarafında execute edilen 
bir `flow`un herhangi bir aşamasında iş akışının başlatılması da söz konusu olabilir. Bu şekilde `JBPM` tarafındaki 
herhangi bir iş akışı `SWF` tarafından yönlendirilip, gerekli kullanıcı girdilerini temin ederek `task`ları 
çalıştırılabilmektedir.

`SWF` tarafından `JBPM` iş akışlarının ve `task`ların yönetilmesi için geliştirdiğimiz temel entegrasyon çözümleri şöyle 
sıralayabiliriz:

1. `SWF` tarafında yeni bir `flow` başlaması ile birlikte `JBPM` tarafında da yeni bir iş akışı başlatmak
2. `Flow` içerisinde herhangi bir adımda iş akışına bulunduğu `node`’un default `transition`’ından devam etmesini söylemek
3. `Flow` içerisinden iş akışını save etmek
4. `SWF` tarafında yeni bir `flow` başlatırken `JBPM` tarafındaki belirli bir `task`’ı `SWF` tarafında execute etmek için 
yüklemek (`task` – `flow` eşleşmesi)
`Flow` sonlanırken `flow`un karşılık geldiği `JBPM task`ını default `transition`’ı veya spesifik herhangi başka bir 
5. `transition`’ını tetikleyerek sonlandırmak
Herhangi bir `JBPM process` ve `task instance`’ının barındırdığı değişkenlere normal `SWF` scoped değişkenlere erişime 
6. benzer biçimde erişim sağlamak (`processScope`, `taskScope`)

`SWF` de bu işlemleri gerçekleştirmek için `FlowExecutionListener` vasıtası ile `flow` event’lerinden yararlandık. `JBPM` 
tarafında belirli kullanıcılara atanan `task`’ların `SWF` tarafında hangi `flow`’u tetikleyeceği konusunu ise 
`JBPM process` definition oluştururken `task` isimlerini `SWF flow` isimleri ile eşleştirerek çözdük. Herhangi bir `flow` 
sonlanırken `JBPM` tarafındaki `task`’ında hangi `transition`’ı sinyal edeceğini `flow`’u end-state’e getiren son 
`transition`’ın event id’si ile `JBPM transition` name’lerini eşleştirerek tespit ettik.

Şimdi `JbpmFlowExecutionListener` üzerinde detaylı bir inceleme yaparak `SWF-JBPM` entegrasyonunu detaylandıralım.

`SWF` tarafında yeni bir `flow` içerisinden herhangi bir `JBPM process`’inin yeni bir `instance`’ını yaratmak için `flow` 
tanımı içerisine `jbpmStartProcess` attribute’unu tanımladık. `jbpmStartProcess` attribute’una değer olarak `process` 
tanım adının verilmesi yeterlidir.

```java
public void sessionstarted(RequestContext context, FlowSession session) {
	String processName = (String) session.getDefinition().getAttributes().get("jbpmStartProcess");
	if(processName != null){
		ProcessInstance processInstance = workflowService.createProcessInstance(processName);
		session.getScope().put("processInstance", processInstance);
	}
}
```


`JbpmFlowExecutionListener`’ın `sessionstarted` metodu içerisinde `jbpmStartProcess` attribute değeri varsa, bu değere 
karşılık gelen `process` tanımından yeni bir `processInstance` yaratılır. `JBPM` operasyonlarını gerçekleştirmek için 
geliştirdiğimiz `workflowService` spring managed bean’ı arka tarafta bütün `JBPM` erişimlerini `Spring Modules` 
projesinin `JbpmTemplate` sınıfı ile gerçekleştirmektedir. Örnek olarak `workflowService.createProcessInstance` 
metoduna bakabiliriz.

```java
public ProcessInstance createProcessInstance(final String processName) {
	return (ProcessInstance) jbpmTemplate.execute(new JbpmCallback() {
		public Object doInJbpm(JbpmContext context) throws JbpmException {
			ProcessDefinition processDefinition = context.getGraphSession().findLatestProcessDefinition(processName);
			if(processDefinition == null) {
				throw new ProcessDefinitionNotFoundException("JBPM process with name " + processName + " not found.");
			}
			return processDefinition.createProcessInstance();
		}
	});
}
```

`Flow` içerisinde `JBPM process instance`’ının aktif `node’una devam sinyali göndermek için ise `SWF transition`ı 
içerisinde kullanılabilen `jbpmSignalProcess` attribute’unu tanımladık.

```java
public void stateEntered(RequestContext context, StateDefinition previousState, StateDefinition state) {
	TransitionDefinition lastTransition = context.getCurrentTransition();
	if (lastTransition != null) {
		Boolean saveProcess = (Boolean) lastTransition.getAttributes().get("jbpmSaveProcess", false);
		Boolean signalProcess = (Boolean) lastTransition.getAttributes().get("jbpmSignalProcess", false); 
		if (signalProcess)
			workflowService.signalProcessInstanceProcessInstance) context.getFlowScope().get("processInstance""processInstance" class="wiki wikinew">?;
		if (saveProcess)
			workflowService.saveProcessInstanceProcessInstance) context.getFlowScope().get(“processInstance""processInstance"" class="wiki wikinew">?; 
	}
}
```

`JbpmFlowExecutionListener`’da `stateEntered` metodu içerisinde `flow`’un yeni `state’e geçmesine neden olan son 
`transition` içerisinde `jbpmSignalProcess` attribute’una bakılır. Eğer bu attribute mevcut ve değeri true ise 
`workflowService` yardımı ile halihazırda `flow scope’da` tutulan `JBPM processInstance’a` bir sonraki `node’a geçmesi 
için sinyal gönderilir.

`stateEntered` metodunda son `transition`’da aynı zamanda `jbpmSaveProcess` attribute’u aranır. Eğer bu attribute mevcut 
ve değeri true ise `processInstance` `workflowService` ile save edilir.

`SWF` içerisinde yeni bir `flow` başlatılırken bu `flow’a` karşılık gelen `task’a` ait bir `task instance`ını JBPM 
tarafından alıp `flow` içinden yürütmek için `flow request url’ine` ilgili `task instance’ının id’sini 
`_jbpmTaskId request` parametresi ile veriyoruz.

```java
public void sessionstarting(RequestContext context, FlowSession session, MutableAttributeMap input) {
	String task = context.getRequestParameters().get(“_jbpmTaskId”);
	if (task != null) {
		TaskInstance taskInstance = workflowService.getTaskInstance(Long.parseLong(task));
		if (taskInstance != null) {
			context.getFlowScope().put(“taskInstance”, taskInstance);
			context.getFlowScope().put(“processInstance”, taskInstance.getProcessInstance());
		}
	}
}
```

`sessionstarting` metodu içerisinde halihazırdaki request’in `_jbpmTaskId request` parametresinin değeri alınarak, bu 
id’ye karşılık gelen `JBPM taskInstance nesnesi` ve onun ait olduğu `processInstance nesnesi workflowService` vasıtası 
ile alınır ve `SWF`’nin `flow scope’una konur. Böylece başlatılan `flow’un` ilgili `JBPM süreci ile bağlantılandırılması 
sağlanmış olur.

`SWF` tarafında bir `flow` sona ererken `JBPM` tarafında da o `flow’un` karşılığı olan `taskInstance’ının` sonlandırılması 
gerekir. Bu ya `JBPM task’ının` default `transition’ını` ya da spesifik bir `transition’ı` belirterek gerçekleştirilebilir. 
Bunun için `SWF state’leri` içerisinde kullanılmak üzere `jbpmEndTask` ve `jbpmEndTaskWithTransition attribute’larını` 
tanımladık.

```java
public void sessionEnding(RequestContext context, FlowSession session, String outcome, MutableAttributeMap output) {
	Boolean endTask = (Boolean) context.getCurrentState().getAttributes().get("jbpmEndTask", false);
	Boolean endTaskWithTransition = (Boolean) context.getCurrentState().getAttributes().get("jbpmEndTaskWithTransition", false);

	if(endTask && endTaskWithTransition) {
		throw new IllegalStateException("Only jbpmEndTask or jbpmEndTaskWithTransition is allowed");
	}

	if (endTask) {
		workflowService.endTaskInstanceTaskInstance) context.getFlowScope().get("taskInstance""taskInstance"" class="wiki wikinew">?;
	} else if(endTaskWithTransition) {
		TransitionDefinition lastTransition = context.getCurrentTransition();
		String jbpmTransition = (String)session.getScope().get("jbpmTransition");
		if(StringUtils.isEmpty(jbpmTransition)) {
			jbpmTransition = (String) lastTransition.getAttributes().get("jbpmTransition",String.class);
		}

		if(jbpmTransition == null) {
			jbpmTransition = context.getCurrentEvent().getId();
		}
		workflowService.endTaskInstance((TaskInstance) context.getFlowScope().get("taskInstance"),jbpmTransition);
	}
}
```

`JbpmFlowExecutionListener`’ın `sessionEnding` metodunda `end-state`’de `jbpmEndTask` veya `jbpmEndTaskWithTransition` 
attribute’larından birisine bakılır. Eğer `jbpmEndTask` mevcutsa ve değeri true ise `flow scope’da` tutulan 
JBPM taskInstance’ı default transition çağırılarak sonlandırılır. Eğer `jbpmEndTaskWithTransition` attribute’u mevcutsa 
ve değeri true ise bu sefer `JBPM task’ının` hangi `transition’ının` sinyal edilerek sonlandırılacağı tespit edilir. 
Burada önce `flow scope jbmTransition değişkeninden` bu değer alınır, eğer burada mevcut değilse bu sefer `end-state’e` 
gelmemize neden olan son `transition’da jbpmTransition attribute’una` bakılır. Burada da mevcut değilse transition adı 
`end-state’e` gelmemize neden olan `transition’ı` tetikleyen event’in id’si olarak set edilerek `taskInstance` 
sonlandırılır.

`SWF` tarafında `taskInstance` ve `processInstance nesnelerinin` barındırdıkları değişkenlere erişmek, bu değişkenlere 
yeni değer atamak için `SWF’nin` kendi `scopelarındaki` değişkenlere erişim, bunları manipülasyon için sağladığı syntax’a 
benzer bir syntax sağlamak için `RequestControlContextImpl` sınıfını extend ettik. Maalesef `SWF` her `flow request’i` 
için bu `ExtendedRequestControlContextImpl sınıfını` kullanması için yeterli esnekliği sağlamadığından yeni sınıfı 
`RequestControlContextImpl ile` aynı “full classname”’de yaratarak class loading aşamasında `SWF’nin sınıfı` yerine bizim 
sınıfımızın yüklenmesini sağladık. Bu sayede `process ve task instance’larındaki` değişkenlere `flow tanımlarında` erişim 
şu şekilde olabiliyor:

Bir sonraki yazımda ise küçük bir iş akışı örneği üzerinden giderek `JBPM üzerindeki` çalışmalarımızdan bahsetmeye devam 
edeceğim.
