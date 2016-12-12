xquery version "3.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
import module namespace functx="http://www.functx.com";

(: Would be nice to be able to accept uploaded file, or xml? :)
declare variable $id {request:get-parameter('id', '')}; 
declare variable $collection {request:get-parameter('collection', '')}; 


(: Need upload option for running external TEI through process upload and download results, or have as API? :)
(: May want to recognize names only in desc and notes, events? or everywhere? not nest in placeNames of course. :)
(: Also, how about multiplule ids in ref? if there are multiple matches? seems fair to me, but not sure :)

(: Search within $nodes for matches to a regular expression $pattern and apply a $highlight function :)
declare function local:highlight-matches($nodes as node()*, $pattern as xs:string*, $highlight as function(xs:string) as item()* ) { 
    for $node in $nodes
    return
        typeswitch ( $node )
            (: Ignores existing teiHeader :)
            case element(tei:teiHeader) return
                $node
            (: Ignores existing placeNames :)    
            case element(tei:placeName) return
                $node
            (: Ignores existing placeNames :)    
            case element(tei:persName) return
                $node    
            (: Ignores existing bibl :)    
            case element(tei:bibl) return
                $node                
            case element() return
                element { QName(namespace-uri($node), local-name($node)) } { $node/@*, local:highlight-matches($node/node(), $pattern, $highlight) }
            case text() return
                let $normalized := replace($node, '\s+', ' ')
                for $segment in analyze-string($normalized, $pattern)/node()
                return
                    if ($segment instance of element(fn:match)) then 
                        $highlight($segment/string())
                    else 
                        $segment/string()
            case document-node() return
                document { local:highlight-matches($node/node(), $pattern, $highlight) }
            default return
                $node
};

declare function local:get-id($string as xs:string) as xs:string*{
    let $id := collection('/db/apps/srophe-data/data/places/tei')//tei:placeName[@xml:lang='en'][. = $string]/following-sibling::tei:idno[@type='URI'][starts-with(.,'http://syriaca.org')]
    return $id/text()
};


let $pattern := 
string-join(
    for $placeName in collection('/db/apps/srophe-data/data/places/tei')//tei:placeName[@xml:lang='en']
    order by string-length($placeName) descending
    return $placeName/text(),'|')

let $highlight := function($string as xs:string) { <placeName xmlns="http://www.tei-c.org/ns/1.0" ref="{local:get-id($string)}">{$string}</placeName>} 
return 
<div>
{
(: Test what to run NER on :)
if($collection) then  
    for $rec in collection($collection)
    let $doc-uri := document-uri($rec/root())
    let $file-name := tokenize($doc-uri,'/')[last()]
    let $collection-uri :=  substring-before($doc-uri,concat('/',$file-name))
    let $node := $rec/root()
    let $new-node := local:highlight-matches($node, $pattern, $highlight)
    return 
        if(matches($node/descendant::tei:body/node(),$pattern)) then 
            xmldb:store($collection-uri, xmldb:encode-uri($file-name), $new-node)
        else ()
        
else if($id) then     
    for $rec in collection($global:data-root)//tei:idno[@type='URI'][. = $id]
    let $doc-uri := document-uri($rec/root())
    let $file-name := tokenize($doc-uri,'/')[last()]
    let $collection-uri :=  substring-before($doc-uri,$file-name)
    let $node := $rec/root()
    return    
        xmldb:store($collection-uri, xmldb:encode-uri($file-name), local:highlight-matches($node, $pattern, $highlight))
else 
    let $node := 
    <TEI xmlns="http://www.tei-c.org/ns/1.0"
     xmlns:tei="http://www.tei-c.org/ns/1.0"
     xmlns:syriaca="http://syriaca.org"
     xmlns:saxon="http://saxon.sf.net/"
     xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
     xmlns:functx="http://www.functx.com"
     xml:lang="en">
   <teiHeader>
      <fileDesc>
         <titleStmt>
            <title level="a" xml:lang="en">Abā, Bishop of Ninevah — <foreign xml:lang="syr">ܐܒܐ</foreign>
            </title>
            <title level="m">Qadishe: A Guide to the Syriac Saints</title>
            <sponsor>Syriaca.org: The Syriac Reference Portal</sponsor>
            <funder>The International Balzan Prize Foundation</funder>
            <funder>The National Endowment for the Humanities</funder>
            <principal>David A. Michelson</principal>
            <editor role="general"
                    ref="http://syriaca.org/documentation/editors.xml#jnmsaintlaurent">Jeanne-Nicole Mellon Saint-Laurent</editor>
            <editor role="general"
                    ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A. Michelson</editor>
            <editor role="creator"
                    ref="http://syriaca.org/documentation/editors.xml#jnmsaintlaurent">Jeanne-Nicole Mellon Saint-Laurent</editor>
            <editor role="creator"
                    ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A. Michelson</editor>
            <respStmt>
               <resp>Editing, proofreading, data entry and revision by</resp>
               <name type="person"
                     ref="http://syriaca.org/documentation/editors.xml#jnmsaintlaurent">Jeanne-Nicole Mellon Saint-Laurent</name>
            </respStmt>
            <respStmt>
               <resp>Data architecture and encoding by</resp>
               <name type="person"
                     ref="http://syriaca.org/documentation/editors.xml#dmichelson">David A. Michelson</name>
            </respStmt>
            <respStmt>
               <resp>Editing, Syriac data conversion, data entry, and reconciling by</resp>
               <name ref="http://syriaca.org/documentation/editors.xml#akane">Adam P. Kane</name>
            </respStmt>
            <respStmt>
               <resp>Editing and Syriac data proofreading by</resp>
               <name ref="http://syriaca.org/documentation/editors.xml#abarschabo">Aram Bar Schabo</name>
            </respStmt>
            <respStmt>
               <resp>Entries adapted from the work of</resp>
               <name type="person" ref="http://syriaca.org/documentation/editors.xml#jmfiey">Jean Maurice Fiey</name>
            </respStmt>
            <respStmt>
               <resp>Entries adapted from the work of</resp>
               <name type="person" ref="http://syriaca.org/documentation/editors.xml#uzanetti">Ugo Zanetti</name>
            </respStmt>
            <respStmt>
               <resp>Entries adapted from the work of</resp>
               <name type="person" ref="http://syriaca.org/documentation/editors.xml#cdetienne">Claude Detienne</name>
            </respStmt>
         </titleStmt>
         <editionStmt>
            <edition n="1.0"/>
         </editionStmt>
         <publicationStmt>
            <authority>Syriaca.org: The Syriac Reference Portal</authority>
            <idno type="URI">http://syriaca.org/person/1094/tei</idno>
            <availability>
               <licence target="http://creativecommons.org/licenses/by/3.0/">
                  <p>Distributed under a Creative Commons Attribution 3.0 Unported License.</p>
               </licence>
            </availability>
            <date>2015-08-06-04:00</date>
         </publicationStmt>
         <sourceDesc>
            <p>Born digital.</p>
         </sourceDesc>
      </fileDesc>
      <encodingDesc>
         <editorialDecl>
            <p>This record created following the Syriaca.org guidelines. 
                        Documentation available at: <ref target="http://syriaca.org/documentation">http://syriaca.org/documentation</ref>.</p>
            <interpretation>
               <p>Approximate dates described in terms of centuries or partial centuries
                            have been interpreted as documented in 
                            <ref target="http://syriaca.org/documentation/dates.html">Syriaca.org Dates</ref>.</p>
            </interpretation>
         </editorialDecl>
         <classDecl>
            <taxonomy>
               <category xml:id="syriaca-headword">
                  <catDesc>The name used by Syriaca.org for document titles, citation, and
                                disambiguation. These names have been created according to the
                                Syriac.org guidelines for headwords: <ref target="http://syriaca.org/documentation/headwords.html">http://syriaca.org/documentation/headwords.html</ref>.</catDesc>
               </category>
               <category xml:id="syriaca-anglicized">
                  <catDesc>An anglicized version of a name, included to facilitate
                                searching.</catDesc>
               </category>
            </taxonomy>
            <taxonomy>
               <category xml:id="syriaca-author">
                  <catDesc>A person who is relevant to the Guide to Syriac Authors</catDesc>
               </category>
               <category xml:id="syriaca-saint">
                  <catDesc>A person who is relevant to the Bibliotheca Hagiographica
                                Syriaca.</catDesc>
               </category>
            </taxonomy>
         </classDecl>
      </encodingDesc>
      <profileDesc>
         <langUsage>
            <language ident="syr">Unvocalized Syriac of any variety or period</language>
            <language ident="syr-Syrj">Vocalized West Syriac</language>
            <language ident="syr-Syrn">Vocalized East Syriac</language>
            <language ident="en">English</language>
            <language ident="en-x-gedsh">Names or terms Romanized into English according to the standards 
                        adopted by the Gorgias Encyclopedic Dictionary of the Syriac Heritage</language>
            <language ident="ar">Arabic</language>
            <language ident="fr">French</language>
            <language ident="de">German</language>
            <language ident="la">Latin</language>
         </langUsage>
      </profileDesc>
      <revisionDesc>
         <change who="http://syriaca.org/documentation/editors.xml#dmichelson"
                 n="1.0"
                 when="2015-08-06-04:00">CREATED: person</change>
      </revisionDesc>
   </teiHeader>
   <text>
      <body>
         <listPerson>
            <person xml:id="saint-1094" ana="#syriaca-saint">
               <persName xml:id="name1094-1" xml:lang="syr" syriaca-tags="#syriaca-headword">ܐܒܐ</persName>
               <persName xml:id="name1094-2"
                         xml:lang="en-x-gedsh"
                         syriaca-tags="#syriaca-headword">Abā, Bishop of Ninevah</persName>
               <persName xml:id="name1094-3" xml:lang="en">Aba of Ninevah</persName>
               <persName xml:id="name1094-4" xml:lang="en">Aba</persName>
               <persName xml:id="name1094-5" xml:lang="fr-x-fiey" source="#bibl1094-1">ĀBĀI</persName>
               <idno type="URI">http://syriaca.org/person/1094</idno>
               <idno type="FIEY">3</idno>
               <sex value="M" source="#bibl1094-1">male</sex>
               <floruit source="#bibl1094-1"
                        from="0585"
                        syriaca-computed-start="0585"
                        to="0590"
                        syriaca-computed-end="0590">0585-0590</floruit>
               <note>Fiey provides the following bibliographic citations: <quote source="#bibl1094-1">Fiey, "Bar 'Eta", 10-14. BSO, I, 4- 5 (J. Habbi).</quote>
               </note>
               <note type="abstract">Abā was a Bishop of Nineveh who was martyred under shah Shapur II.</note>
               <event type="veneration" source="#bibl1094-1">
                  <desc>The saint is venerated on 17 December, East Syrians.</desc>
               </event>
               <bibl xml:id="bib1094-1">
                  <title level="m" xml:lang="fr">Saints Syriaques</title>
                  <title level="a" xml:lang="fr">ĀBĀI</title>
                  <ptr target="http://syriaca.org/bibl/650"/>
                  <citedRange unit="entry">3</citedRange>
               </bibl>
               <bibl xml:id="bib1094-3">
                  <author>Fiey</author>
                  <title>"Bar 'Eta"</title>
                  <citedRange>10-14.</citedRange>
               </bibl>
               <bibl xml:id="bib1094-4">
                  <author>J. Habbi</author>
                  <title>BSO</title>
                  <citedRange>I, 4-5</citedRange>
               </bibl>
            </person>
         </listPerson>
      </body>
   </text>
</TEI>
    return local:highlight-matches($node, $pattern, $highlight)        
    }
    </div>