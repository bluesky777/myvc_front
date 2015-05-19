angular.module("myvcFrontApp")

.filter('juicioValorativo', [ ->
	(nota, escalas, desempenio)->

		jucio = {}

		angular.forEach escalas, (escala)->
			if nota >= escala.porc_inicial and nota <= escala.porc_final
				jucio.desempenio = escala.desempenio
				jucio.valoracion = escala.valoracion

		if desempenio
			return jucio.desempenio
		else
			return jucio.valoracion
])

.filter('soloAsignaturasConPerdidas', ['$filter', ($filter)->
	(asignaturas, only)->

		if only

			@asignaturas_resp = []

			angular.forEach asignaturas, (asignatura)->
				unidades = $filter('soloUnidadesConPerdidas')(asignatura.unidades, true)

				if unidades.length
					@asignaturas_resp.push asignatura
				

			return @asignaturas_resp
		else
			return asignaturas
])

.filter('soloUnidadesConPerdidas', ['$filter', ($filter)->
	(unidades, only)->

		if only

			@unidades_resp = []

			angular.forEach unidades, (unid)->
				subunids = $filter('soloSubunidadesPerdidas')(unid.subunidades, true)

				if subunids.length
					@unidades_resp.push unid
				

			return @unidades_resp
		else
			return unidades
])

.filter('soloSubunidadesPerdidas', ['Perfil', (Perfil)->
	(subunidades, only)->

		if only
			@subunidades_resp = []

			angular.forEach subunidades, (subunid)->
				if !subunid.nota
					console.log 'sununidad', subunid
				
				if subunid.nota.nota < Perfil.User().nota_minima_aceptada
					@subunidades_resp.push subunid

			return @subunidades_resp

		else
			return subunidades
])
