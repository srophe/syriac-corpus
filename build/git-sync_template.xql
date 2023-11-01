xquery version "3.1";

(:~ 
 : Webhook endpoint for Srophe Web Application 
 : XQuery endpoint to respond to Github webhook requests.  
 : 
 : Requirements
 :  - githubxq library : http://exist-db.org/lib/githubxq 
 :  - EXPath Crypto library : http://expath.org/spec/crypto
 :  - eXist-db 3.0 or greater 
 :  - Must be run with elevated privileges: sm:chmod(xs:anyURI('/db/apps/srophe/modules/git-sync.xql'), "rwsr-xr-x")
 :
 : @author Winona Salesky
 : @version 2.0 
 :)
 
import module namespace githubxq="http://exist-db.org/lib/githubxq";

let $data := request:get-data()
return 
    githubxq:execute-webhook($data, 
        '/db/apps/syriac-corpus-data',
        'https://github.com/srophe/syriac-corpus',
        'development',
        '${SECRET_KEY}',
        '')
