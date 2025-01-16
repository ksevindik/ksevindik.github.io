# Ortak Tomcat Kurulumu Üzerinden Birden Fazla Instance Çalıştırmak

Zaman zaman aynı makina üzerinde birden fazla Tomcat instance’ını çalıştırmak isteyebiliriz. Bunun için farklı Tomcat 
kurulumları yapmak kolay ve hızlı bir çözüm olabilir, ancak güncelleme ve projelerin paylaştıkları kütüphanelerin yönetimi 
açısından bakıldığında ortak bir Tomcat kurulumu üzerinden birden fazla Tomcat instance’ını çalıştırmak çok daha avantajlı 
olmaktadır.

Ortak Tomcat kurulumu üzerinden farklı instance’lar çalıştırmak için, Tomcat’i belirli bir dizine kurduktan sonra her bir 
node için ayrı ayrı dizinler oluşturarak aşağıdaki işlemleri yapmalısınız. Örneğin `/work/tools/servers/apache-tomcat/apache-tomcat-7.0.16`
Tomcat kurulu dizinimiz olsun. `/work/tools/servers/apache-tomcat` dizini altında da `node1` ve `node2` isimli iki dizin 
oluşturalım. Her ikisi de ayrı ayrı Tomcat instance’larının çalıştırılmasında kullanılacaktır.

Öncelikle, kurulum dizinindeki `bin` dizininin altındaki `setenv.sh` ve `tomcat-juli.jar` dosyalarını node dizinlerinin 
altında `bin` dizini oluşturarak kopyalayınız. Eğer Tomcat instance’larına özel env değişiklikleri yapamayacaksanız, 
`setenv.sh` dosyasını kopyalamanıza gerek yoktur.

Kurulum dizinindeki `conf` dizinini altındaki dosyalar ile birlikte aynen node dizinlerinin altına kopyalayınız. 
`node/conf/server.xml` dosyaları içerisinde her node için farklı http, https, ajp, shutdown portları belirleyiniz.

Node dizinleri altında `temp`, `logs`, `webapps`, `work` dizinlerini oluşturunuz. Test amacıyla kurulum dizini altındaki 
`/webapps/ROOT` dizinini `node/webapps` dizini altına kopyalayabilirsiniz.

Artık her bir instance’ı ayrı ayrı çalıştırabilirsiniz. Start ve stop işlemleri için Tomcat kurulumunun `bin` dizini 
altındaki `startup` ve `shutdown` scriptlerini kullanabilmek için `CATALINA_BASE`, `CATALINA_HOME` ve `BASEDIR` ortam 
değişkenlerini tanımlamanız gerekmektedir. `CATALINA_BASE` her bir node için farklı olacaktır. `CATALINA_HOME` ve `BASEDIR` 
değişkenleri ise Tomcat kurulum dizinini göstermelidir.

Aşağıda Linux veya Unix ortamlarında kullanmak üzere yazdığım script’i bu iş için kullanabilirsiniz.

```shell
!/bin/bash
    this script is used to start and stop tomcat nodes which
    share same tomcat installation 


if $# -ne 2 ; then
echo "usage: ./run-node.sh  "
exit -1;
fi
export NODE_HOME=/work/tools/servers/apache-tomcat
export TOMCAT_HOME=$NODE_HOME/apache-tomcat-7.0.16

if ! -d $NODE_HOME/ ; then
echo $HOME_HOME/$2 node directory does not exist
exit -1;
fi

export CATALINA_BASE=$NODE_HOME/$2
export CATALINA_HOME=$TOMCAT_HOME
export BASEDIR=$CATALINA_HOME

if = "start" ; then
$CATALINA_HOME/bin/startup.sh;
elif = "stop" ; then
$CATALINA_HOME/bin/shutdown.sh;
else
echo "invalid first parameter :" $1
echo "you can either start or stop a node"
exit -1;
fi
```
