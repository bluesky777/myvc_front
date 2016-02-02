angular.module('myvcFrontApp')

.directive('anunciosDir',['App', 'Restangular', 'toastr', (App, Restangular, toastr)-> 

	restrict: 'E'
	templateUrl: "#{App.views}panel/anunciosDir.tpl.html"


	link: (scope, iElem, iAttrs)->
		Restangular.one('ChangesAsked/to-me').customGET().then((r)->
			scope.changes_asked_to_me = r
		, (r2)->
			toastr.error 'No se pudo traer los anuncios.'
		)

])
