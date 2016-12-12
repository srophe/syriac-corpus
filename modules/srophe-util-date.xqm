xquery version "3.0";

module namespace sdate="http://srophe.org/ns/srophe-util-date";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";

declare variable $sdate:resource-uri {request:get-parameter('resource', '')};

(:~
 : Insert custom generated dates
 : Takes @notBefore, @notAfter, @to, @from, and @when and adds a syriaca computed date attribute for searching.
 : @param $resource-uri path to resource or collection  
 :)    
 (:
declare function sdate:add-custom-dates(){
   if(ends-with($sdate:resource-uri),'.xml') then sdate:custom-dates-doc($sdate:resource-uri)
   else sdate:custom-dates-coll($sdate:resource-uri)
                            
};
:)
declare function sdate:custom-dates-coll($resource-uri, $comment, $editor){
for $doc in collection($config:data-root)//tei:body 
return 
    (
            sdate:notAfter($doc),
            sdate:notBefore($doc),
            sdate:to($doc),
            sdate:from($doc),
            sdate:when($doc),
            if(sdate:notAfter($doc) = 'success') then
                sdate:add-change-log($doc,$comment, $editor)
            else if(sdate:notBefore($doc) = 'success') then 
                sdate:add-change-log($doc,$comment, $editor)
            else if(sdate:to($doc) = 'success') then 
                sdate:add-change-log($doc,$comment, $editor)
            else if(sdate:from($doc) = 'success') then 
                sdate:add-change-log($doc,$comment, $editor)
            else if(sdate:when($doc) = 'success') then 
                sdate:add-change-log($doc,$comment, $editor)
            else () 
    ) 
};

declare function sdate:custom-dates-doc($resource-uri, $comment, $editor){
for $doc in doc($resource-uri)//tei:body 
return 
    (
            sdate:notAfter($doc),
            sdate:notBefore($doc),
            sdate:to($doc),
            sdate:from($doc),
            sdate:when($doc),
            if(sdate:notAfter($doc) = 'success') then 
                sdate:add-change-log($doc,$comment, $editor)
            else if(sdate:notBefore($doc) = 'success') then 
                sdate:add-change-log($doc,$comment, $editor)
            else if(sdate:to($doc) = 'success') then 
                sdate:add-change-log($doc,$comment, $editor)
            else if(sdate:from($doc) = 'success') then 
                sdate:add-change-log($doc,$comment, $editor)
            else if(sdate:when($doc) = 'success') then 
                sdate:add-change-log($doc,$comment, $editor)
            else ()    
    ) 
};

(:~
 : Take data from @notAfter, check for existing @syriaca-computed-end
 : if none, format date and add @syriaca-computed-end as xs:date
 : @param $doc document node
:)
declare function sdate:notAfter($doc){
    for $date in $doc/descendant-or-self::*/@notAfter
    let $date-norm := if(starts-with($date,'0000') and string-length($date) eq 4) then '0001-01-01'
                          else if(string-length($date) eq 4) then concat(string($date),'-01-01')
                          else if(string-length($date) eq 5) then concat(string($date),'-01-01')
                          else if(string-length($date) eq 7) then concat(string($date),'-01')
                          else string($date)
    return 
        if($date[@syriaca-computed-end]) then ()
        else   
            try {
                    (update insert attribute syriaca-computed-end {xs:date($date-norm)} into $date/parent::*,'success')
                } 
            catch * 
                {
                    <date place="{$doc/@xml:id}">{(string($date-norm), "Error:", $err:code)}</date>
                }     
};

(:~
 : Take data from @notBefore, check for existing @syriaca-computed-start
 : if none, format date and add @syriaca-computed-start as xs:date
 : @param $doc document node
:)
declare function sdate:notBefore($doc){
    for $date in $doc/descendant-or-self::*/@notBefore
    let $date-norm := if(starts-with($date,'0000') and string-length($date) eq 4) then '0001-01-01'
                          else if(string-length($date) eq 4) then concat(string($date),'-01-01')
                          else if(string-length($date) eq 5) then concat(string($date),'-01-01')
                          else if(string-length($date) eq 7) then concat(string($date),'-01')
                          else string($date)
    return 
        if($date[@syriaca-computed-start]) then ()
        else   try {
                        (update insert attribute syriaca-computed-start {xs:date($date-norm)} into $date/parent::*,'success')
                     } catch * {
                         <date place="{$doc/@xml:id}">{
                             (string($date-norm), "Error:", $err:code)
                         }</date>
                     }
};

(:~
 : Take data from @to, check for existing @syriaca-computed-end
 : if none, format date and add @syriaca-computed-end as xs:date
 : @param $doc document node
:)
declare function sdate:to($doc){
    for $date in $doc/descendant-or-self::*/@to
    let $date-norm := if(starts-with($date,'0000') and string-length($date) eq 4) then '0001-01-01'
                          else if(string-length($date) eq 4) then concat(string($date),'-01-01')
                          else if(string-length($date) eq 5) then concat(string($date),'-01-01')
                          else if(string-length($date) eq 7) then concat(string($date),'-01')
                          else string($date)
    return 
        if($date[@syriaca-computed-end]) then ()
        else   try {
                        (update insert attribute syriaca-computed-end {xs:date($date-norm)} into $date/parent::*,'success')
                     } catch * {
                         <date place="{$doc/@xml:id}">{
                             (string($date-norm), "Error:", $err:code)
                         }</date>
                     }
};

(:~
 : Take data from @from, check for existing @syriaca-computed-start
 : if none, format date and add @syriaca-computed-start as xs:date
 : @param $doc document node
:)
declare function sdate:from($doc){
    for $date in $doc/descendant-or-self::*/@from
    let $date-norm := if(starts-with($date,'0000') and string-length($date) eq 4) then '0001-01-01'
                          else if(string-length($date) eq 4) then concat(string($date),'-01-01')
                          else if(string-length($date) eq 5) then concat(string($date),'-01-01')
                          else if(string-length($date) eq 7) then concat(string($date),'-01')
                          else string($date)
    return 
        if($date[@syriaca-computed-start]) then ()
        else   try {
                        (update insert attribute syriaca-computed-start {xs:date($date-norm)} into $date/parent::*,'success')
                     } catch * {
                         <date place="{$doc/@xml:id}">{
                             (string($date-norm), "Error:", $err:code)
                         }</date>
                     }
};

(:~
 : Take data from @when, check for existing @syriaca-computed-start
 : if none, format date and add @syriaca-computed-start as xs:date
:)
declare function sdate:when($doc){
    for $date in $doc/descendant-or-self::*/@when
    let $date-norm := if(starts-with($date,'0000') and string-length($date) eq 4) then '0001-01-01'
                          else if(string-length($date) eq 4) then concat(string($date),'-01-01')
                          else if(string-length($date) eq 5) then concat(string($date),'-01-01')
                          else if(string-length($date) eq 7) then concat(string($date),'-01')
                          else string($date)
    return 
        if($date[@syriaca-computed-start]) then ()
        else   try {
                        (update insert attribute syriaca-computed-start {xs:date($date-norm)} into $date/parent::*, 'success')
                     } catch * {
                         <date place="{$doc/@xml:id}">{
                             (string($date-norm), "Error:", $err:code)
                         }</date>
                     }
};

(:~
 : Insert new change element and change publication date
 : @param $editor from form and $comment from form
 : ADDED: syriaca-computed-start and syriaca-computed-end attributes for searching
 : ADDED: latitude and longitude from Pleiades
:)
declare function sdate:add-change-log($doc, $comment, $editor){
       (update insert 
            <change xmlns="http://www.tei-c.org/ns/1.0" who="http://syriaca.org/documentation/editors.xml#wsalesky" when="{current-date()}">
                ADDED: syriaca-computed-start and syriaca-computed-end attributes for searching
            </change>
          preceding $doc/ancestor::*//tei:teiHeader/tei:revisionDesc/tei:change[1],
          update value $doc/ancestor::*//tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date with current-date()
          )
};
