angular.module('myvcFrontApp')

.directive('BoletinAlumnoDir',['App', (App)-> 

	restrict: 'EA'
	templateUrl: "#{App.views}informes/boletinAlumno.tpl.html"
	scope: 
		alumno: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if
		

])
