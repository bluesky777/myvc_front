angular.module('myvcFrontApp')

.factory('NotasServ', ['$http', '$q', ($http, $q) ->
	notas = {}

	notas.detalladas = (asignatura_id, profe_id, con_asignaturas)->
		d = $q.defer();

		$http.put('::notas/detailed', {asignatura_id: asignatura_id, profesor_id: profe_id, con_asignaturas: con_asignaturas}).then((r)->
			d.resolve r.data
		, (r2)->
			d.reject r2
		)

		return d.promise

	return notas

])



.factory('AlumnosSinMatriculaServ', ['$http', '$q', '$filter', ($http, $q, $filter) ->
	alumnos = []

	alumnosResp = {}

	alumnosResp.alumnos = ()->
		d = $q.defer();

		if alumnos.length > 0
			d.resolve alumnos
		else
			$http.get('::alumnos/sin-matriculas').then((r)->
				alumnos = r.data
				d.resolve alumnos
			, (r2)->
				d.reject r2
			)

		return d.promise


	return alumnosResp

])



.factory('InformesServ', ['$http', '$q', '$filter', ($http, $q, $filter) ->
	datos = {}

	datosResp = {}

	datosResp.datos = ()->
		d = $q.defer();

		if datos.year
			d.resolve datos
		else
			$http.put('::informes/datos').then((r)->
				datos = r.data
				d.resolve datos
			, (r2)->
				d.reject r2
			)

		return d.promise


	return datosResp

])



.factory('EscalasValorativasServ', ['$http', '$q', '$filter', ($http, $q, $filter) ->
	escalas = []

	escalasr = {}

	escalasr.escalas = ()->
		d = $q.defer();

		if escalas.length > 0
			d.resolve escalas
		else
			$http.get('::escalas').then((r)->
				escalas = r.data
				for escala in escalas
					escala.orden 		= parseInt(escala.orden)
					escala.perdido 		= parseInt(escala.perdido)
					escala.porc_final 	= parseInt(escala.porc_final)
					escala.porc_inicial = parseInt(escala.porc_inicial)
					escala.id 			= parseInt(escala.id)
					escala.year_id 		= parseInt(escala.year_id)

				d.resolve escalas
			, (r2)->
				d.reject r2
			)

		return d.promise

	escalasr.escala_maxima = ()->
		escala_max = $filter('orderBy')(escalas, 'orden')[escalas.length-1]
		return escala_max

	return escalasr

])

.factory('AusenciasServ', ['$http', '$q', ($http, $q) ->
	ausencias = {}

	ausencias.detalladas = (asignatura_id)->
		d = $q.defer();

		$http.get('::ausencias/detailed/'+asignatura_id).then((r)->
			d.resolve r.data
		, (r2)->
			d.reject r2
		)

		return d.promise

	return ausencias

])

.factory('ComportamientoServ', ['$http', '$q', ($http, $q) ->
	comportamientos = {}

	comportamientos.detallados = (grupo_id)->
		d = $q.defer();

		$http.get('::nota_comportamiento/detailed/'+grupo_id).then((r)->
			d.resolve r.data
		, (r2)->
			d.reject r2
		)

		return d.promise

	return comportamientos

])
