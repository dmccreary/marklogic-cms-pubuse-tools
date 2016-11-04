xquery version "1.0-ml";
import module namespace style = "http://danmccreary.com/style" at "/modules/style.xqy";

(:
Metrics
		
:)

declare option xdmp:output "method=html";

let $title := 'CMS Public Use File Document Metrics'

let $content := 
<div class="content">
    <div class="row">
      <div class="col-md-4">
       <h4>{$title}</h4>
       <table class="table table-striped table-bordered table-hover table-condensed ">
          <thead>
             <tr>
                <tr>
                   <th class="col-md-2">Metric</th>
                   <th class="col-md-1">Value</th>
                   <th class="col-md-1">list</th>
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
          </tbody>
       </table>
       </div>
       

       </div>
       Elapsed Time: {xdmp:elapsed-time() div xs:dayTimeDuration('PT1S') } seconds.
    </div>                                           

return style:assemble-page($title, $content)