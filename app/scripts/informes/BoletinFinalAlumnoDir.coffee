angular.module('myvcFrontApp')

.directive('boletinFinalAlumnoDir',['App', 'Perfil', (App, Perfil)-> 

	restrict: 'EA'
	templateUrl: "==informes/boletinFinalAlumnoDir.tpl.html"
	scope: 
		grupo: "="
		year: "="
		alumno: "="
		config: "="
		escalas: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

		scope.USER = Perfil.User()
		scope.USER.nota_minima_aceptada = parseInt(scope.USER.nota_minima_aceptada)
		scope.perfilPath = App.images+'perfil/'

		#console.log scope.config.orientacion
])


.filter('promedioPeriodo', [ ->
	(input, periodo_id) ->
		
		suma = 0
		for asig in input

			for defini in asig.definitivas
				if defini.periodo_id
					if parseFloat(defini.periodo_id) == parseFloat(periodo_id)
						suma += parseFloat(defini.DefMateria)

		promedio = suma / input.length


		return promedio
])





