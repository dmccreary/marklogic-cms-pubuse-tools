xquery version "1.0-ml";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace style = "http://uhc.com/odm/style" at "/modules/style.xqy";
import module namespace mdrs = "http://marklogic.com/metadata-registry-search" at "/modules/metadata-registry-search.xqy";
import module namespace oref = "http://optum.com/odm/c360/common/optum-specific-referece-data" at "/modules/reference-optum.xqy";
import module namespace srch = "http://optum.com/odm/meta-data/search"  at "/modules/search-can-util.xqy";

declare namespace m = "http://optum.com/odm/metadata-registry";
declare namespace d = "http://optum.com/odm/canonical-data-element";
declare namespace c = "http://marklogic.com/metadata-registry/core-data-element";

declare option xdmp:mapping "false";
declare option xdmp:output "method=html";
declare option xdmp:output "encoding=utf-8";
declare option xdmp:output "indent=yes";

let $title := "Canonical Data Element Search"

(:
return
  if (not($q)) then
    <error><message>q is a required parameter</message></error>
  else (: continue :)
:)
let $q := xdmp:get-request-field('q', 'sort:relevance')
let $start := xs:positiveInteger(xdmp:get-request-field('start', '1'))
let $page-length := xs:positiveInteger(xdmp:get-request-field('page-length', '10'))
let $debug := xs:boolean(xdmp:get-request-field('debug', 'false'))
let $filter := xdmp:get-request-field("filter", 'none')
let $end := $start + $page-length - 1

(:
<return-facets>true</return-facets>
    <constraint name="cloud">
      <range type="xs:string">
        <facet-option>frequency-order</facet-option>
        <facet-option>descending</facet-option>
        <facet-option>limit=20</facet-option>
        <element ns="http://optum.com/odm/canonical-data-element" name="canonical-name"/>
        <element ns="http://optum.com/odm/canonical-data-element" name="representation-term"/>
        <element ns="http://optum.com/odm/canonical-data-element" name="subject-area"/>
        <element ns="http://optum.com/odm/canonical-data-element" name="xml-schema-type"/>
      </range>
    </constraint>
:)

let $options := $srch:srch-opt

let $search-results := search:search($q, $options)

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
        <h4>{map:get($srch:srch-constraint-labels, 'EN') ! map:get(.,$facet-name)}</h4>
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
                search:remove-constraint($qtext, $this, $srch:srch-opt)
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
        <h4>Search Results</h4>
        
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
      
        <span class="field-label">Total Count:</span> {format-number($count, '#,###')}<br/>
        <span class="field-label">Query:</span>"{$q}"<br/>
        <a href="{xdmp:get-request-path()}?debug=true&amp;q={$q}">View Debug</a><br/>
      {
      style:prev-next-pagination-links($start, $page-length, $count, $q)
      }
      {
      for $result at $count in $search-results/search:result
        let $uri := $result/@uri/string()
        let $doc := doc($uri)/d:data-element
        let $root-name := local-name($doc)
        let $canonical := $root-name = 'data-element'
      return
        <div class="data-element-hit">

          <div class ="canonical">
            <span class="green-uri">{$uri}</span><br/>
            <span class="field-label">Data Element Type:</span> Canonical<br/>
            <span class="field-label">Canonical Name:</span> <b>{$doc/d:canonical-name/text()}</b><br/>
            <span class="field-label">Representation Term:</span> <b>{$doc/d:representation-term/text()}</b><br/>
            <span class="field-label">Subject Area:</span> <b>{$doc/d:subject-area/text()}</b><br/>
            <span class="field-label">Part Of Type:</span> <b>{$doc/d:part-of-type/text()}</b><br/>
          </div>

        {
        for $snippet in $result/search:snippet
        return
          <div class="snippit">
          {
          for $match in $snippet/search:match
            let $path := $match/@path
            (: convert the path to get the last element
             the last() does not work when there are emphaisis elements.
             let $para-num := substring-after(tokenize($path, '/')[last()], '*:')
            :)
            let $definition-indicator := ends-with($path, 'definition')
            let $representation-term-indicator := ends-with($path, 'representation-term')
          return
            <div class="match">
            {
            if ($definition-indicator) then
              <span class="field-label">Definition:</span>
             else
              ()
            }
            {
            if ($representation-term-indicator) then
              ()
            else
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
          <div class="button-actions">
            <span class="field-label">Actions:</span>
            <a class="btn btn-info" role="button" href="/views/view-canonical-data-element.xqy?uri={$uri}">View Data Element</a>
            <a class="btn btn-info" role="button"  href="/views/view-xml.xqy?uri={$uri}">View XML</a>
            <a class="btn btn-info" role="button"  href="/scripts/add-to-wantlist.xqy?uri={$uri}">Add to Wantlist</a>
            <a class="btn btn-info" role="button"  href="/transforms/convert-to-core.xqy?uri={$uri}">Convert to Core Data Element</a>
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
