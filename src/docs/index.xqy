xquery version "1.0-ml";
import module namespace style = "http://danmccreary.com/style" at "/modules/style.xqy";

let $title := 'List of Resourse for CMS Claims Public Use Files'

let $content :=
<div class="content">
  <h4>{$title}</h4>
  <a></a>
</div>

return style:assemble-page($title, $content)