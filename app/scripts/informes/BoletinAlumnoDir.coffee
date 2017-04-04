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


		# Para el gráfico
		scope.colors = ['#25f1aa'];
		scope.labels = [];
		scope.data = [];

		for asignatura in scope.alumno.asignaturas
			scope.labels.push asignatura.alias_materia
			scope.data.push asignatura.nota_asignatura

		scope.series = ['Asignaturas'];
		scope.options = {
			title: {
				fontSize: 12,
				text: 'Definitivas por asignaturas'
				display: true
				fontColor: '#000'
			}	
		}
		scope.altura_chart = 140
		scope.indiceColor = 0
		scope.colores = [
			['#25f1aa']
			['#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999', '#999999']
			['#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa', '#25f1aa']
		]

		scope.colorCorrespondiente = ()->
			scope.colors = scope.colores[scope.indiceColor]
			return scope.colores[scope.indiceColor]

		scope.toogleIndiceColor = ()->
			scope.indiceColor = scope.indiceColor + 1
			if scope.indiceColor > scope.colores.length - 1 
				scope.indiceColor = 0

			scope.colors = scope.colores[scope.indiceColor]
			console.log scope.indiceColor, scope.colors
			scope.altura_chart = 140
			scope.altura_chart = 141

		

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



