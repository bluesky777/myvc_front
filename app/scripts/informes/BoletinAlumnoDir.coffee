angular.module('myvcFrontApp')

.directive('boletinAlumnoDir',['App', 'Perfil', (App, Perfil)-> 

	restrict: 'EA'
	templateUrl: "==informes/boletinAlumnoDir.tpl.html"
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
		scope.views = App.views
		#console.log scope.config.orientacion
])





.filter('cantPerdidasPer', [ ->
	(input, periodo_id, alum_id) ->
		
		@suma = 0

		angular.forEach input, (periodo, key) ->
			
			periodo_id = parseFloat(periodo_id)
			per_id = parseFloat(periodo.id)

			if per_id == periodo_id
				@suma = @suma +  periodo.cantNotasPerdidas
		
	
		
		if @suma == 0
			return ''

		return @suma
])



