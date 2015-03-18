angular.module('myvcFrontApp')

.filter('unsafe', ['$sce', ($sce)->
	return (val)->
		return $sce.trustAsHtml(val)
])


# update popover template for binding unsafe html
angular.module("template/popover/popover.html", []).run(["$templateCache", ($templateCache)->
	$templateCache.put("template/popover/popover.html",
		"<div class=\"popover {{placement}}\" ng-class=\"{ in: isOpen(), fade: animation() }\">\n" +
		"  <div class=\"arrow\"></div>\n" +
		"\n" +
		"  <div class=\"popover-inner\">\n" +
		"      <h3 class=\"popover-title\" ng-bind-html=\"title | unsafe\" ng-show=\"title\"></h3>\n" +
		"      <div class=\"popover-content\"ng-bind-html=\"content | unsafe\"></div>\n" +
		"  </div>\n" +
		"</div>\n" +
		"")
])
