xquery version "3.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function local:render($node) {
    typeswitch($node)
        case text() return $node
        case element(tei:bibl) return
            element { QName(namespace-uri($node), local-name($node)) }
            { $node/@*, attribute ana {'partialTranslation'}, local:recurse($node) }
        case element(tei:author) return
            element { QName(namespace-uri($node), local-name($node)) }
            { $node/@*, replace($node/text(),'\(partielle\)','') }
        default return $node
};

declare function local:recurse($node) {
    for $child in $node/node()
    return
        local:render($child)
};

for $work in collection('/db/apps/srophe-data/data/works')//tei:bibl[tei:author[contains(.,'(partielle)')]]
return  update replace $work with local:render($work)