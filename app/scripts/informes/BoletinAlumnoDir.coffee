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




		scope.options = {
			chart: {
				type: 'discreteBarChart',
				height: 180,
				width: scope.$parent.ancho_chart, #  En BoletinesPeriodoCtrl.coffee
				margin : {
					top: 20,
					right: 20,
					bottom: 60,
					left: 55
				},
				useInteractiveGuideline: true,
				x: (d)-> return d.label; 
				y: (d)-> return d.value; 
				showValues: true,
				valueFormat: (d)-> d3.format(',.0f')(d);
				transitionDuration: 500
			}
			title: {
				enable: false,
				text: 'Definitivas por asignaturas'
			}
		};


		valores = []
		for asignatura in scope.alumno.asignaturas
			valores.push { label: asignatura.alias_materia, value: asignatura.nota_asignatura },
		
		scope.data = [{
			key: "Definitivas de asignaturas",
			values: valores
		}];




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



