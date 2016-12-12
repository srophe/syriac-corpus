xquery version "3.0";

module namespace trigger='http://exist-db.org/xquery/trigger';
import module namespace sutil="http://srophe.org/ns/srophe-util" at "srophe-util-date.xqm";
import module namespace sutil="http://srophe.org/ns/srophe-util" at "srophe-util-name.xqm";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";


declare function trigger:after-create-document($uri as xs:anyURI){
    xmldb:login('/db/apps/srophe/', 'admin', '', true())
};
                
