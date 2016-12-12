xquery version "3.0";

module namespace sname="http://srophe.org/ns/srophe-util-name";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(:~
 : Add alternate names for improved searching triggered when document is uploaded. 
:)
declare function sname:left-half-ring-pers($recs){
    for $names in $recs//tei:persName[contains(.,'ʿ')]
    let $parent := $names/ancestor::tei:person
    let $rec-id := substring-after($parent/@xml:id,'-')
    let $pers-name := string-join($names/node(),' ')
    let $new-name := 
        (
            <persName xmlns="http://www.tei-c.org/ns/1.0" xml:id="{concat('name',$rec-id,'-',(count($parent/tei:persName) + 1))}" xml:lang="en-xsrp1" syriaca-tags="#syriaca-simplified-script">{replace($pers-name,'ʿ','')}</persName>,
            <persName xmlns="http://www.tei-c.org/ns/1.0" xml:id="{concat('name',$rec-id,'-',(count($parent/tei:persName) + 2))}" xml:lang="en-xsrp1" syriaca-tags="#syriaca-simplified-script">{replace($pers-name,'ʿ','‘')}</persName>
        )
    return 
        if($parent/tei:persName[@syriaca-tags="#syriaca-simplified-script"]) then 
            if($parent/tei:persName[@syriaca-tags="#syriaca-simplified-script"]/text() = replace($pers-name,'ʿ','')) then ()
            else (update insert $new-name following $parent/tei:persName[last()],sname:do-change-stmt($names))
        else
           (update insert $new-name following $parent/tei:persName[last()],sname:do-change-stmt($names))
};
(:collection('/db/apps/srophe/data/persons/tei'):)
declare function sname:right-half-ring-pers($recs){
    for $names in $recs//tei:persName[contains(.,'ʾ')]
    let $parent := $names/ancestor::tei:person
    let $rec-id := substring-after($parent/@xml:id,'-')
    let $pers-name := string-join($names/node(),' ')
    let $new-name := 
        (
            <persName xmlns="http://www.tei-c.org/ns/1.0" xml:id="{concat('name',$rec-id,'-',(count($parent/tei:persName) + 1))}" xml:lang="en-xsrp1" syriaca-tags="#syriaca-simplified-script">{replace($pers-name,'ʿ','')}</persName>,
            <persName xmlns="http://www.tei-c.org/ns/1.0" xml:id="{concat('name',$rec-id,'-',(count($parent/tei:persName) + 2))}" xml:lang="en-xsrp1" syriaca-tags="#syriaca-simplified-script">{replace($pers-name,'ʿ','’')}</persName>
        )
    return 
        if($parent/tei:persName[@syriaca-tags="#syriaca-simplified-script"]) then 
            if($parent/tei:persName[@syriaca-tags="#syriaca-simplified-script"]/text() = replace($pers-name,'ʿ','')) then ()
            else (update insert $new-name following $parent/tei:persName[last()],sname:do-change-stmt($names))
        else
           (update insert $new-name following $parent/tei:persName[last()],sname:do-change-stmt($names))
};

(:collection('/db/apps/srophe/data/places/tei'):)
declare function sname:left-half-ring-place($recs){
    for $names in $recs//tei:placeName[contains(.,'ʿ')]
    let $parent := $names/ancestor::tei:place
    let $rec-id := substring-after($parent/@xml:id,'-')
    let $place-name := $names/text()
    let $new-name := 
        (
            <placeName xmlns="http://www.tei-c.org/ns/1.0" xml:id="{concat('name',$rec-id,'-',(count($parent/tei:placeName) + 1))}" xml:lang="en-xsrp1" syriaca-tags="#syriaca-simplified-script">{replace($place-name,'ʿ','')}</placeName>,
            <placeName xmlns="http://www.tei-c.org/ns/1.0" xml:id="{concat('name',$rec-id,'-',(count($parent/tei:placeName) + 2))}" xml:lang="en-xsrp1" syriaca-tags="#syriaca-simplified-script">{replace($place-name,'ʿ','‘')}</placeName>
        )
    return 
        if($parent/tei:placeName[@syriaca-tags="#syriaca-simplified-script"]) then 
            if($parent/tei:placeName[@syriaca-tags="#syriaca-simplified-script"]/text() = replace($place-name,'ʿ','')) then ()
            else
                (update insert $new-name following $parent/tei:placeName[last()],sname:do-change-stmt($names))
        else
           (update insert $new-name following $parent/tei:placeName[last()],sname:do-change-stmt($names))
};

declare function sname:right-half-ring-place($recs){
    for $names in $recs//tei:placeName[contains(.,'ʾ')]
    let $parent := $names/ancestor::tei:place
    let $rec-id := substring-after($parent/@xml:id,'-')
    let $place-name := $names/text()
    let $new-name := 
        (
            <placeName xmlns="http://www.tei-c.org/ns/1.0" xml:id="{concat('name',$rec-id,'-',(count($parent/tei:placeName) + 1))}" xml:lang="en-xsrp1" syriaca-tags="#syriaca-simplified-script">{replace($place-name,'ʿ','')}</placeName>,
            <placeName xmlns="http://www.tei-c.org/ns/1.0" xml:id="{concat('name',$rec-id,'-',(count($parent/tei:placeName) + 2))}" xml:lang="en-xsrp1" syriaca-tags="#syriaca-simplified-script">{replace($place-name,'ʿ','’')}</placeName>
        )
    return 
        if($parent/tei:placeName[@syriaca-tags="#syriaca-simplified-script"]) then 
            if($parent/tei:placeName[@syriaca-tags="#syriaca-simplified-script"]/text() = replace($place-name,'ʿ','')) then ()
            else
                (update insert $new-name following $parent/tei:placeName[last()],sname:do-change-stmt($names))
        else
           (update insert $new-name following $parent/tei:placeName[last()],sname:do-change-stmt($names))
};

declare function sname:do-change-stmt($names){
    let $change := 
        <change xmlns="http://www.tei-c.org/ns/1.0" who="http://syriaca.org/documentation/editors.xml#wsalesky" when="{current-date()}">ADDED: Add alternate names for search functionality.</change>
    return
        (
         update insert $change preceding $names/ancestor::tei:TEI/tei:teiHeader/tei:revisionDesc/tei:change[1],
         update value $names/ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date with current-date())
};

declare function sname:run-script-stmt($uri){
    let $recs :=     
        if(ends-with($uri, '.xml')) then doc($uri)/child::*
        else 
            for $docs in collection($uri)
            return $docs
    return             
        (
            sname:left-half-ring-pers($recs),
            sname:right-half-ring-pers($recs),
            sname:left-half-ring-place($recs),
            sname:right-half-ring-place($recs)
        )
};
