angular.module('myvcFrontApp')

.directive('boletinAlumnoDir',['App', 'Perfil', (App, Perfil)-> 

	restrict: 'EA'
	templateUrl: "#{App.views}informes/boletinAlumnoDir.tpl.html"
	scope: 
		grupo: "="
		year: "="
		alumno: "="
		config: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

		scope.USER = Perfil.User()
		scope.perfilPath = App.images+'perfil/'

		#console.log scope.config.orientacion
])
