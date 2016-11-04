xquery version "1.0-ml";
import module namespace style = "http://danmccreary.com/style" at "/modules/style.xqy";
declare namespace in="https://www.cms.gov/claims/inpatient";
declare namespace out="https://www.cms.gov/claims/outpatient";
declare namespace r="https://www.cms.gov/claims/rx";
(:
Metrics
		
:)

declare option xdmp:output "method=html";

let $title := 'CMS Public Use File Document Metrics'

let $content := 
<div class="content">
    <div class="row">
      <div class="col-md-6">
       <h4>{$title}</h4>
       <table class="table table-striped table-bordered table-hover table-condensed ">
          <thead>
             <tr>
                <tr>
                   <th class="col-md-2">Metric</th>
                   <th class="col-md-1">Value</th>
                   <th class="col-md-3">List</th>
                </tr>
             </tr>
          </thead>
          <tbody>
            <tr>
               <td class="right col-md-3">
                 <span class="field-label">Total Document Count: </span> 
               </td>
               <td class="number">
                 {format-number(xdmp:estimate(/), '#,###')}
               </td>
               <td>
                  
               </td>
            </tr>
            <tr>
               <td class="right col-md-3">
                 <span class="field-label">Inpatient Claims: </span> 
               </td>
               <td class="number">
                 {format-number(xdmp:estimate(/in:inpatient-claim), '#,###')}
               </td>
               <td>
                  <a href="list-inpatient-claims.xqy">List Inpatient Claims</a>
               </td>
            </tr>
            <tr>
               <td class="right col-md-3">
                 <span class="field-label">Outpatient Claims: </span> 
               </td>
               <td class="number">
                 {format-number(xdmp:estimate(/out:outpatient-claim), '#,###')}
               </td>
               <td>
                  <a href="list-inpatient-claims.xqy">List Outpatient Claims</a>
               </td>
            </tr>
            <tr>
               <td class="right col-md-3">
                 <span class="field-label">Prescription Claims: </span> 
               </td>
               <td class="number">
                 {format-number(xdmp:estimate(/r:rx), '#,###')}
               </td>
               <td>
                  <a href="list-inpatient-claims.xqy">List Prescription Claims</a>
               </td>
            </tr>
          </tbody>
       </table>
       </div>
       

       </div>
       Elapsed Time: {xdmp:elapsed-time() div xs:dayTimeDuration('PT1S') } seconds.
    </div>                                           

return style:assemble-page($title, $content)