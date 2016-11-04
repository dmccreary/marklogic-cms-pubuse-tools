xquery version "1.0-ml";
import module namespace style = "http://danmccreary.com/style" at "/modules/style.xqy";
declare namespace in="https://www.cms.gov/claims/inpatient";

let $title := 'List Inpatient Claims'

let $start := xs:positiveInteger(xdmp:get-request-field('start', '1'))
let $page-length := xs:positiveInteger(xdmp:get-request-field('page-length', '10'))
let $debug := xs:boolean(xdmp:get-request-field('debug', 'false'))

(: or use cts:search(/in:inpatient-claim, cts:or-query(()) :)
let $inpatient-claims := /in:inpatient-claim

let $total-count := count($inpatient-claims)
let $content :=
<div class="content">
  <h4>{$title}</h4>
  
  <span class="field-label">Total Claims:</span> {format-number($total-count, '#,###')}
  
  {style:prev-next-pagination-links($start, $page-length, $total-count)}
  <table class="table table-striped table-bordered table-hover table-condensed">
    <thead>
      <tr>
         <th>#</th>
         <th>Code</th>
         <th>Amount</th>
         <th>view-xml</th>
      </tr>
      </thead>
    <tbody>{
     for $claim at $count in subsequence($inpatient-claims, $start, $page-length)
     let $uri := xdmp:node-uri($claim)
     return
        <tr>
           <td>{$count}</td>
           <td>{$uri}</td>
           <td>{format-number($claim/in:CLM_PMT_AMT/text(), '#,###')}</td>
           <td><a href="/views/view-xml.xqy?uri={$uri}">view-xml</a></td>
        </tr>
      }</tbody>
   </table>
   Elapsed Time: {xdmp:elapsed-time() div xs:dayTimeDuration('PT1S') } seconds.
</div>

return style:assemble-page($title, $content)