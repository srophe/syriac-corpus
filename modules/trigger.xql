xquery version "1.0";
(:
    A simple XQuery for an XQueryTrigger that
    logs all trigger events for which it is executed
    in the file /db/triggers-log.xml
:)
module namespace trigger="http://exist-db.org/xquery/trigger";
import module namespace sdate="http://srophe.org/ns/srophe-util-date" at "srophe-util-date.xqm";
import module namespace sname="http://srophe.org/ns/srophe-util-name" at "srophe-util-name.xqm";

declare namespace xmldb="http://exist-db.org/xquery/xmldb";

declare function trigger:before-create-collection($uri as xs:anyURI) {
    local:log-event("before", "create", "collection", $uri)
};
declare function trigger:after-create-collection($uri as xs:anyURI) {
    local:log-event("after", "create", "collection", $uri)
};
declare function trigger:before-copy-collection($uri as xs:anyURI, $new-uri as xs:anyURI) {
    local:log-event("before", "copy", "collection", concat("from: ", $uri, " to: ", $new-uri))
};
declare function trigger:after-copy-collection($new-uri as xs:anyURI, $uri as xs:anyURI) {
    local:log-event("after", "copy", "collection", concat("from: ", $uri, " to: 
", $new-uri))
};
declare function trigger:before-move-collection($uri as xs:anyURI, $new-uri as xs:anyURI) {
    local:log-event("before", "move", "collection", concat("from: ", $uri, " to: ", $new-uri))
};
declare function trigger:after-move-collection($new-uri as xs:anyURI, $uri as xs:anyURI) {
    local:log-event("after", "move", "collection", concat("from: ", $uri, " to: ", $new-uri))
};
declare function trigger:before-delete-collection($uri as xs:anyURI) {
    local:log-event("before", "delete", "collection", $uri)
};
declare function trigger:after-delete-collection($uri as xs:anyURI) {
    local:log-event("after", "delete", "collection", $uri)
};
declare function trigger:before-create-document($uri as xs:anyURI) {
    (local:log-event("before", "create", "document", $uri),sdate:custom-dates-doc($uri,'Add custom dates.','wsalesky'),sname:run-script-stmt($uri))
};
declare function trigger:after-create-document($uri as xs:anyURI) {
    local:log-event("after", "create", "document", $uri)
};
declare function trigger:before-update-document($uri as xs:anyURI) {
    local:log-event("before", "update", "document", $uri)
};
declare function trigger:after-update-document($uri as xs:anyURI) {
    (local:log-event("after", "update", "document", $uri),sdate:custom-dates-doc($uri,'Add custom dates.','wsalesky'),sname:run-script-stmt($uri))
};
declare function trigger:before-copy-document($uri as xs:anyURI, $new-uri as xs:anyURI) {
    local:log-event("before", "copy", "document", concat("from: ", $uri, " to: "
, $new-uri))
};
declare function trigger:after-copy-document($new-uri as xs:anyURI, $uri as xs:anyURI) {
    local:log-event("after", "copy", "document", concat("from: ", $uri, " to: ", 
$new-uri))
};
declare function trigger:before-move-document($uri as xs:anyURI, $new-uri as xs:anyURI) {
    local:log-event("before", "move", "document", concat("from: ", $uri, " to: ", $new-uri))
};
declare function trigger:after-move-document($new-uri as xs:anyURI, $uri as xs:anyURI) {
    local:log-event("after", "move", "document", concat("from: ", $uri, " to: ", $new-uri))
};
declare function trigger:before-delete-document($uri as xs:anyURI) {
    local:log-event("before", "delete", "document", $uri)
};
declare function trigger:after-delete-document($uri as xs:anyURI) {
    local:log-event("after", "delete", "document", $uri)
};
declare function local:log-event($type as xs:string, $event as xs:string, 
$object-type as xs:string, $uri as xs:string) {
    let $log-collection := "/db"
    let $log := "triggers-log.xml"
    let $log-uri := concat($log-collection, "/", $log)
    return
        (
        (: create the log file if it does not exist :)
        if (not(doc-available($log-uri))) then
            xmldb:store($log-collection, $log, <triggers/>)
        else ()
        ,
        (: log the trigger details to the log file :)
        update insert <trigger event="{string-join(($type, $event, $object-type
), "-")}" uri="{$uri}" timestamp="{current-dateTime()}"/> into doc($log-uri
)/triggers
        )
};