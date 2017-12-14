angular.module("myvcFrontApp")

.directive("contenteditable", ()->
  return {
    restrict: "A",
    require: "ngModel",
    link: (scope, element, attrs, ngModel)->

      read = ()->
        ngModel.$setViewValue(element.html())
      

      ngModel.$render = ()->
        element.html(ngModel.$viewValue || 0)

      element.bind("blur keyup change", ()->
        scope.$apply(read)
      )
  }
)