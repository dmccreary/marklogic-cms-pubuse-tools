xquery version "1.0-ml";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace style = "http://danmccreary.com/style" at "/modules/style.xqy";
declare namespace c="http://cbinsights.com/company";


let $title := "Company Search"

let $q := xdmp:get-request-field('q')

return
  if (not($q)) then
    <error><message>q is a required parameter</message></error>
  else (: continue :)
  
let $start := xs:positiveInteger(xdmp:get-request-field('start', '1'))
let $page-length := xs:positiveInteger(xdmp:get-request-field('page-length', '10'))
let $debug := xs:boolean(xdmp:get-request-field('debug', 'false'))
let $filter := xdmp:get-request-field("filter", 'none')
let $end := $start + $page-length - 1

let $options :=
  <options xmlns="http://marklogic.com/appservices/search">
    <additional-query>
      <cts:directory-query depth="infinity" xmlns:cts="http://marklogic.com/cts">
        <cts:uri>/sources/cbinsights/</cts:uri>
      </cts:directory-query>
    </additional-query>
    <return-facets>true</return-facets>
    <constraint name="Country">
      <range type="xs:string">
        <facet-option>frequency-order</facet-option>
        <facet-option>descending</facet-option>
        <facet-option>limit=20</facet-option>
        <element ns="http://cbinsights.com/company" name="Country"/>
      </range>
    </constraint>
    <constraint name="State">
      <range type="xs:string">
        <facet-option>frequency-order</facet-option>
        <facet-option>descending</facet-option>
        <facet-option>limit=20</facet-option>
        <element ns="http://cbinsights.com/company" name="State"/>
      </range>
    </constraint>
    <constraint name="Business-Sector">
      <range type="xs:string">
        <facet-option>frequency-order</facet-option>
        <facet-option>descending</facet-option>
        <facet-option>limit=20</facet-option>
        <element ns="http://cbinsights.com/company" name="Sector"/>
      </range>
    </constraint>
    <constraint name="Industry">
      <range type="xs:string">
        <facet-option>frequency-order</facet-option>
        <facet-option>descending</facet-option>
        <facet-option>limit=20</facet-option>
        <element ns="http://cbinsights.com/company" name="Industry"/>
      </range>
    </constraint>
    <constraint name="Sub-Industry">
      <range type="xs:string">
        <facet-option>frequency-order</facet-option>
        <facet-option>descending</facet-option>
        <facet-option>limit=20</facet-option>
        <element ns="http://cbinsights.com/company" name="Sub-Industry"/>
      </range>
    </constraint>
    <constraint name="Total-Funding">
      <range type="xs:decimal">
        <facet-option>frequency-order</facet-option>
        <facet-option>descending</facet-option>
        <element ns="http://cbinsights.com/company" name="Total_Funding"/>
         <bucket name="0-1" ge="0" lt="1">0 - 1</bucket>
         <bucket name="1-2" ge="1" lt="2">1-2</bucket>
         <bucket name="2-5" ge="2" lt="5">2 - 5</bucket>
         <bucket name="5-10" ge="5" lt="10">5 - 10</bucket>
         <bucket name="10-20" ge="10" lt="20">10 - 20</bucket>
         <bucket name="20-50" ge="20" lt="50">20 - 50</bucket>
         <bucket name="50-100" ge="50" lt="100">50 - 100</bucket>
         <bucket name="100+" ge="100">100+</bucket>
      </range>
    </constraint>
    <constraint name="Investors">
      <range type="xs:string">
        <facet-option>frequency-order</facet-option>
        <facet-option>descending</facet-option>
        <facet-option>limit=20</facet-option>
        <element ns="http://cbinsights.com/company" name="investor"/>
      </range>
    </constraint>
    <constraint name="Lists">
      <range type="xs:string">
        <facet-option>frequency-order</facet-option>
        <facet-option>descending</facet-option>
        <facet-option>limit=20</facet-option>
        <element ns="http://cbinsights.com/company" name="list"/>
      </range>
    </constraint>
  </options>

let $search-results := search:search($q, $options, $start, $page-length)

(:
<search:response total="1234"
:)
let $count := xs:nonNegativeInteger($search-results/@total)

return
  if ($debug) then
    <debug-results>
       <q>{$q}</q>
       <count>{$search-results/@total/string()}</count>
       {$search-results}
    </debug-results>
  else (: continue :)

(:
 {style:prev-next-pagination-links-query($start, $page-length, $count)}

 <search:facet name="subject-area" type="xs:string">
    <search:facet-value name="claimadjudicated" count="5">claimadjudicated</search:facet-value>
 :)
let $content :=
<div class="content white-background">
  <div class="row">
  <div class="col-md-2 left-margin">
    {
    for $facet in $search-results/search:facet
      let $facet-count := fn:count($facet/search:facet-value/@count)
      let $facet-name := fn:data($facet/@name)
    return
      if ($facet-count > 0 ) then
        <div>
        <h4>{$facet-name}</h4>
        {
        let $facet-items :=
          for $val in $facet/search:facet-value
            let $print := if ($val/text()) then
              $val/text()
            else
              'Unknown'
        let $qtext := ($search-results/search:qtext)
        let $this :=
              if ( fn:matches($val/@name/string(), '\W') ) then (:are there any non-word characters :)
                '"' || $val/@name/string() || '"' (:if so, quote it :)
              else if ( $val/@name eq "" ) then (:blank?:)
                '""'
              else  (:apparently, just a single word:)
                $val/@name/string()
        let $this := $facet/@name || ':' || $this
        let $selected := fn:matches($qtext, $this, 'i')
        let $icon :=
              if ( $selected ) then
                <img src="/resources/images/red-x.png"/>
              else
                <img src="/resources/images/green-check.png"/>
        let $link :=
              if ( $selected ) then
                search:remove-constraint($qtext, $this, $options)
              else if ( string-length($qtext) gt 0 ) then
                "(" || $qtext || ")" || " AND " || $this
              else
                $this
        let $link := fn:encode-for-uri($link)
        return
            <div>{$icon}<a href="{xdmp:get-invoked-path()}?q={$link}">{fn:lower-case($print)}</a> ({$val/@count/string()})</div>
        return (
          <div>{$facet-items}</div>
        )
        }

        </div>
      else
        <div>&#160;</div>
      }
  </div>
  <div class="col-md-10">
    {if ($search-results) then
      <div class="search-results">
        <h4>{$title} Search Results</h4>
        
        { if ($start gt 1)
        then
           <span><span class="field-label">Start:</span> {$start}</span>
        else ()
        }
        
      { (: only show a non-default page length :)
      if ($page-length = 10) then
        ()
      else
        (concat('Page length: ', $page-length), <br/>)
      }
      
        <span class="field-label">Found:</span> {format-number($count, '#,###')} {' '}
        matches from {format-number(xdmp:estimate(/c:company), '#,###')} {' '} <span class="field-label">companies in</span> 
        {xdmp:elapsed-time() div xs:dayTimeDuration('PT1S') } <span class="field-label">seconds.</span>
        <br/>
        
        <span class="field-label">Query:</span>"{$q}"<br/>
        <a href="{xdmp:get-request-path()}?debug=true&amp;q={$q}">View Debug</a><br/>
      {
      style:prev-next-pagination-links($start, $page-length, $count, $q)
      }
      {
      for $result at $count in $search-results/search:result
        let $uri := $result/@uri/string()
        let $company := doc($uri)/c:company
        let $company-name := $company/c:Company_Name/text()
        let $description := $company/c:Description/text()
        
        return
        <div class="company-hit">
          
          <div class="company">
            {$count + $start - 1}.  {' '}
            <span class="field-label">Company Name: </span> <b>{$company-name}</b>
          </div>

        {
        for $snippet in $result/search:snippet
        return
          <div class="snippit">
          {
            for $match in $snippet/search:match
               let $path := $match/@path/string()
               return
                 <div class="match">
                    <span class="field-label">{substring-after($path, '*:company/*:')}:</span>
                    {
                      for $text-or-highlight in $match/node()
                      return
                        if ($text-or-highlight instance of element()) then
                          <span class="highlight">{$text-or-highlight/text()}</span>
                        else
                          $text-or-highlight
                    }
                 </div>
          }
          </div>
        }
          <div class="green-url"><a href="/views/view-xml.xqy?uri={$uri}">{$uri}</a></div>
          <div class="button-actions">
            <span class="field-label">Actions:</span>
            <a class="btn btn-info" role="button" href="/views/view-company.xqy?uri={$uri}">View Company Details</a>
            <a class="btn btn-info" role="button" href="/forms/add-to-company-list.xqy?uri={$uri}">Add to Company List</a>
         </div>
       </div>
      }
</div>
else
  <div>Your search returned no results. </div>
}
        </div>
    </div>
</div>

return style:assemble-page($title, $content)
