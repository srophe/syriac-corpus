xquery version "3.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

(: Fix notes editions and mss. Link and ammend. :)
(: Check to make sure editions can handle multiple values in corresp :)
declare function local:mss-edits($node){
    for $note in $node//tei:note[@type='MSS'][matches(tei:bibl/text(), '^ed')]/tei:bibl
    return
        if($note/@xml:id) then ()
        else
            let $ed-num :=
                for $segment in analyze-string($note/text(), '^(ed:\s|ed\s\(\d\):\s)')/node()
                return
                    if ($segment instance of element(fn:match)) then
                        for $n in analyze-string($segment,'\d*')
                        return $n/fn:match/text()
                    else ()
            let $num := if(empty($ed-num)) then '1' else $ed-num
            let $new-node :=
                <bibl xmlns="http://www.tei-c.org/ns/1.0" xml:id="{concat('witness',$num)}">
                    {replace($note,'^(ed:\s|ed\s\(\d\):\s)','')}
                </bibl>
            return update replace $note with $new-node
};

declare function local:editions-edits($node){
    for $note in $node//tei:note[@type='editions'][matches(tei:bibl/tei:author,'^\(\d\)')]/tei:bibl
    return
    if($note/@corresp) then ()
    else
        let $ed-num :=
            for $segment in analyze-string($note/tei:author/text(), '^\(\d\)')/node()
            return
                if ($segment instance of element(fn:match)) then
                    for $n in analyze-string($segment,'\d*')
                    return $n/fn:match/text()
                else ()
        let $num := if(empty($ed-num)) then '1' else $ed-num
        let $num-match := concat('(',$num,')')
        let $new-node :=
            <bibl xmlns="http://www.tei-c.org/ns/1.0" source="{$note/@source}" corresp="{concat('#witness',$num)}" n="{$num}">
                {
                    for $c in $note/child::*
                    return
                        if(starts-with($c/text(),$num-match)) then
                            element {node-name($c)}
                                {$c/@*, normalize-space(substring-after($c/text(),$num-match))}
                        else $c
                }
            </bibl>
      return update replace $note with $new-node
};

declare function local:empty-mss($node){
    for $mss in $node//tei:note[@type='editions']/tei:bibl
    let $editions-num := substring-after($mss/@corresp,'#')
    return
        if($node//tei:note[@type='MSS']/tei:bibl[matches(@xml:id,$editions-num)]) then ()
        else
            update insert
                <note xml:lang="en" type="MSS" source="#bib250-1" xmlns="http://www.tei-c.org/ns/1.0">
                    <bibl xml:id="{$editions-num}">The manuscript witnesses for edition {substring-after($editions-num,'witness')} are undetermined.</bibl>
                </note>
            following $node//tei:note[last()]
};

declare function local:add-change-log($node){
       (update insert
            <change xmlns="http://www.tei-c.org/ns/1.0" who="http://syriaca.org/documentation/editors.xml#wsalesky" when="{current-date()}">
               Added xml:id attributes to manuscript notes and corresp attributes to the corresponding editions notes for all BHSE records.
            </change>
          preceding $node/ancestor::*//tei:teiHeader/tei:revisionDesc/tei:change[1],
          update value $node/ancestor::*//tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date with current-date()
          )
};

for $node in collection('/db/apps/srophe-data/data/works')//tei:body[descendant::tei:note[@type='MSS'][matches(tei:bibl/text(), '^ed')]]
return
    (local:mss-edits($node),local:editions-edits($node),local:empty-mss($node),local:add-change-log($node))