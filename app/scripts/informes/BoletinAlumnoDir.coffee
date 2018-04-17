angular.module('myvcFrontApp')

.directive('boletinAlumnoDir',['App', 'Perfil', '$filter', (App, Perfil, $filter)->

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
			#asignatura.nota_asignatura          = $filter('number')(asignatura.nota_asignatura, 0)
			valores.push { label: asignatura.alias_materia, value: asignatura.nota_asignatura }

		scope.data = [{
			key: "Definitivas de asignaturas",
			values: valores
		}];




])




.directive('boletinAlumnoDir2',['App', 'Perfil', '$filter', (App, Perfil, $filter)->

	restrict: 'EA'
	templateUrl: "==informes2/boletinAlumnoDir2.tpl.html"
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
			#asignatura.nota_asignatura          = $filter('number')(asignatura.nota_asignatura, 0)
			valores.push { label: asignatura.alias_materia, value: asignatura.nota_asignatura }

		scope.data = [{
			key: "Definitivas de asignaturas",
			values: valores
		}];




])





.directive('boletinAlumnoDir3',['App', 'Perfil', '$filter', (App, Perfil, $filter)->

	restrict: 'EA'
	templateUrl: "==informes2/boletinAlumnoDir3.tpl.html"
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
		for area in scope.alumno.areas
			for asignatura in area.asignaturas
				valores.push { label: asignatura.alias_materia, value: asignatura['nota_final_per'+scope.USER.numero_periodo] }


		scope.data = [{
			key: "Definitivas de asignaturas",
			values: valores
		}];




])






.directive('boletinAlumnoDir4',['App', 'Perfil', '$filter', (App, Perfil, $filter)->

	restrict: 'EA'
	templateUrl: "==informes2/boletinAlumnoDir4.tpl.html"
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





		for area in scope.alumno.areas
			for asignatura in area.asignaturas

				if asignatura.nota_final_per1 >= scope.USER.nota_minima_aceptada
					asignatura.desempenio_per1 = 'Alcanzado'
				else
					asignatura.desempenio_per1 = 'En proceso'

				if asignatura.nota_final_per2 >= scope.USER.nota_minima_aceptada
					asignatura.desempenio_per2 = 'Alcanzado'
				else if scope.USER.numero_periodo >= 2
					asignatura.desempenio_per2 = 'En proceso'

				if asignatura.nota_final_per3 >= scope.USER.nota_minima_aceptada
					asignatura.desempenio_per3 = 'Alcanzado'
				else if scope.USER.numero_periodo >= 3
					asignatura.desempenio_per3 = 'En proceso'

				if asignatura.nota_final_per4 >= scope.USER.nota_minima_aceptada
					asignatura.desempenio_per4 = 'Alcanzado'
				else if scope.USER.numero_periodo >= 4
					asignatura.desempenio_per4 = 'En proceso'


				for unidad in asignatura.unidades
					if unidad.nota_unidad >= scope.USER.nota_minima_aceptada
						unidad.desempenio = 'Alcanzado'
					else
						unidad.desempenio = 'En proceso'







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

.directive('dynamic', ($compile)->
	return {
		restrict: 'A',
		replace: true,
		link: (scope, ele, attrs)->
			scope.$watch(attrs.dynamic, (html)->
				ele.html(html);
				$compile(ele.contents())(scope);
			);
	};
);

