xquery version "3.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function local:add-change-log($node, $text){
       (update insert
            <change xmlns="http://www.tei-c.org/ns/1.0" who="http://syriaca.org/documentation/editors.xml#wsalesky" when="{current-date()}">{$text}</change>
          preceding $node/ancestor::*//tei:teiHeader/tei:revisionDesc/tei:change[1],
          update value $node/ancestor::*//tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date with current-date()
          )
};

declare function local:get-person-relation($bhse){
    for $person in collection('/db/apps/srophe-data/data/persons')//tei:idno[@type='BHS'][. = $bhse]
    let $pers-rec := $person/parent::*
    let $person-uri := $pers-rec/tei:idno[@type='URI'][starts-with(.,'http://syriaca.org')]
    return $person-uri/text()
};

declare function local:get-work-relation($bhse){
    for $work in collection('/db/apps/srophe-data/data/works')//tei:idno[@type='BHS'][. = $bhse]
    let $work-rec := $work/parent::*
    let $work-uri := $work-rec/tei:idno[@type='URI'][starts-with(.,'http://syriaca.org')]
    let $title := $work-rec/tei:title[starts-with(@syriaca-tags,'#syriaca-headword')][starts-with(@xml:lang,'en')]/text()
    return <title id="{$work-uri}">{$title}</title>
};

declare function local:check-work-bhse($work, $work-uri){
    for $bhse in $work//tei:idno[@type='BHS']
    return
        if(not(empty(local:get-person-relation($bhse)))) then
            <relation xmlns="http://www.tei-c.org/ns/1.0" name="dcterms:subject" active="{$work-uri}" passive="{string-join(local:get-person-relation($bhse),' ')}"
            source="bib{substring-after($work-uri,'/work/')}-1"/>
        else ()
};

declare function local:check-person-bhse($person, $person-uri){
    for $bhse in $person//tei:idno[@type='BHS']
    return
        if(not(empty(local:get-work-relation($bhse)))) then
            local:get-work-relation($bhse)
        else ()

};

declare function local:update-works(){
    for $work in collection('/db/apps/srophe-data/data/works')//tei:body[descendant::tei:idno[@type='BHS']]
    let $work-uri := $work//tei:idno[@type='URI'][starts-with(.,'http://syriaca.org')][1]
    return
        if(not(empty(local:check-work-bhse($work, $work-uri)))) then
            (update insert
            <listRelation xmlns="http://www.tei-c.org/ns/1.0">
                {local:check-work-bhse($work, $work-uri)}
            </listRelation>
            following $work/tei:bibl,
            local:add-change-log($work, 'Added relation element with related persons URIs')
            )
        else ()
};

declare function local:update-persons(){
    for $person in collection('/db/apps/srophe-data/data/persons')//tei:body[descendant::tei:idno[@type='BHS']]
    let $person-name := $person//tei:persName[@syriaca-tags='#syriaca-headword'][starts-with(@xml:lang,'en')]
    let $person-string:= string-join($person-name/text(),' ')
    let $person-uri := $person//tei:idno[@type='URI'][starts-with(.,'http://syriaca.org')][1]
    let $person-id := substring-after($person-uri,'/person/')
    return
        if(not(empty(local:check-person-bhse($person, $person-uri)))) then
            (for $attestation at $position in local:check-person-bhse($person, $person-uri)
            let $title := $attestation/text()
            let $work-uri := $attestation/@id
            return
                update insert
                <event xmlns="http://www.tei-c.org/ns/1.0" type="attestation" xml:id="attestation{$person-id}-{$position}" source="#bib{$person-id}-1">
                    <p xml:lang="en">{$person-string} is commemorated in <title ref="{$work-uri}">{$title}</title>.</p>
                </event>
                preceding $person//tei:bibl[1],
                local:add-change-log($person, 'Added attestation for with related works'))
        else ()
};

(local:update-works(), local:update-persons())