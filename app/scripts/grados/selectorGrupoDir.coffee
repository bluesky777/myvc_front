angular.module('myvcFrontApp')

.directive('selectorGrupoDir',['App', 'Perfil', (App, Perfil)-> 

	restrict: 'EA'
	templateUrl: "==grados/selectorGrupoDir.tpl.html"

	controller: ($scope, App)->

		return;


	

])






