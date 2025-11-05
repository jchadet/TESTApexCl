Organization org=[SELECT Name,IsSandbox FROM Organization LIMIT 1];
String env=org.Name+(org.IsSandbox?' (Sandbox)':' (Prod)');
Map<String,Boolean> r=new Map<String,Boolean>();
Integer total=4;
try{
List<SAP_IntegrationSettings__mdt> s=[SELECT Endpoint__c,Username__c,Password__c FROM SAP_IntegrationSettings__mdt LIMIT 1];
if(!s.isEmpty()){
HttpRequest q=new HttpRequest();
q.setEndpoint(s[0].Endpoint__c);
q.setMethod('GET');
q.setHeader('x-csrf-token','Fetch');
q.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(Blob.valueOf(s[0].Username__c+':'+s[0].Password__c)));
r.put('SAP_BTP',new Http().send(q).getStatusCode()<300);
}else{r.put('SAP_BTP',false);}
}catch(Exception e){r.put('SAP_BTP',false);}
try{
SAPDetailPointServiceCallout.DonneesDemandees d=new SAPDetailPointServiceCallout.DonneesDemandees();
d.donneesGeneralesPoint=true;
SAPDetailPointServiceCallout.SAPResponse res=SAPDetailPointServiceCallout.callSAP('125278EC1','khawla.trimeche@iliadeconsulting.com',d,false,true);
r.put('SAP_Endpoint',res.isSuccess);
}catch(Exception e){r.put('SAP_Endpoint',false);}
try{
HttpRequest q=new HttpRequest();
q.setEndpoint('callout:SAP_Product_Catalog_Service');
q.setMethod('POST');
q.setHeader('Content-Type','application/json');
q.setBody('{"CITY_CODE":"69387","ENERGY":"01","UIL_USAGE":"DOM","CAR":"4\\u202f500","GREEN_OPTION":"FOR","GREEN_RATE":"100","SERVICE_OPT":"0xf926425","REFDATE":"'+DateTime.now().format('yyyyMMdd')+'"}');
r.put('SAP_Catalog',new Http().send(q).getStatusCode()<300);
}catch(Exception e){r.put('SAP_Catalog',false);}
try{
List<SAPContract__x> c=[SELECT ExternalId FROM SAPContract__x LIMIT 1];
r.put('SAP_OData',true);
}catch(Exception e){r.put('SAP_OData',false);}
Integer ok=0;
for(Boolean b:r.values()){if(b)ok++;}
System.debug('\n=== TEST SAP - '+env+' - '+System.now()+' ===');
System.debug('SAP BTP Activation  : '+(r.get('SAP_BTP')?'✓ OK':'✗ KO'));
System.debug('SAP Endpoint Service: '+(r.get('SAP_Endpoint')?'✓ OK':'✗ KO'));
System.debug('SAP Product Catalog : '+(r.get('SAP_Catalog')?'✓ OK':'✗ KO'));
System.debug('SAP OData Connect   : '+(r.get('SAP_OData')?'✓ OK':'✗ KO'));
System.debug('RESULTAT: '+ok+'/'+total+' services operationnels ('+(ok*100/total)+'%)');
