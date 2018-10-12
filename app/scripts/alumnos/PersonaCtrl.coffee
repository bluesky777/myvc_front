'use strict'

angular.module("myvcFrontApp")

.controller('PersonaCtrl', ['$scope', '$state', '$http', 'toastr', '$uibModal', 'App', ($scope, $state, $http, toastr, $modal, App)->
	$scope.data           = {} # Para el popup del Datapicker
	$scope.alumno         = {}
	$scope.religiones     = App.religiones
	$scope.tipos_sangre   = App.tipos_sangre

	$scope.sangres = [{sangre: 'O+'},{sangre: 'O-'}, {sangre: 'A+'}, {sangre: 'A-'}, {sangre: 'B+'}, {sangre: 'B-'}, {sangre: 'AB+'}, {sangre: 'AB-'}]


	if $state.params.tipo == 'alumno'

		$http.put('::alumnos/show', { id: $state.params.persona_id, con_grupos: true }).then (r)->

			$scope.grupos 				      = r.data.grupos
			$scope.tipos_doc 				    = r.data.tipos_doc
			$scope.alumno 				      = r.data.alumno
			$scope.alum_copy            = angular.copy($scope.alumno)

			$scope.alumno.ciudad_nac_id = $scope.alumno.ciudad_nac
			$scope.alumno.ciudad_doc_id = $scope.alumno.ciudad_doc

			$scope.alumno.fecha_retiro      = if $scope.alumno.fecha_retiro     then new Date($scope.alumno.fecha_retiro.replace(/-/g, '\/')) else $scope.alumno.fecha_retiro
			$scope.alumno.fecha_matricula   = if $scope.alumno.fecha_matricula  then new Date($scope.alumno.fecha_matricula.replace(/-/g, '\/')) else $scope.alumno.fecha_matricula
			$scope.alumno.fecha_nac         = if $scope.alumno.fecha_nac        then new Date($scope.alumno.fecha_nac.replace(/-/g, '\/')) else $scope.alumno.fecha_nac

			if $scope.alumno.ciudad_nac == null
				$scope.alumno.pais_nac = {id: 1, pais: 'COLOMBIA', abrev: 'CO'}
				$scope.paisNacSelect($scope.alumno.pais_nac, $scope.alumno.pais_nac)
			else
				$http.get('::ciudades/datosciudad/'+$scope.alumno.ciudad_nac_id).then (r2)->
					$scope.paises 				= r2.data.paises
					$scope.departamentosNac 	= r2.departamentos
					$scope.ciudadesNac 			= r2.ciudades
					$scope.alumno.pais_nac 		= r2.pais
					$scope.alumno.departamento_nac = r2.departamento
					$scope.alumno.ciudad_nac 	= r2.ciudad

			if $scope.alumno.ciudad_doc > 0
				$http.get('::ciudades/datosciudad/'+$scope.alumno.ciudad_doc_id).then (r2)->
					$scope.paises 				= r2.data.paises
					$scope.departamentos 		= r2.departamentos
					$scope.ciudades 			= r2.ciudades
					$scope.alumno.pais_doc 		= r2.pais
					$scope.alumno.departamento_doc = r2.departamento
					$scope.alumno.ciudad_doc 	= r2.ciudad

			if $scope.alumno.tipo_doc
				for tipo_doc in $scope.tipos_doc
					if tipo_doc.id == $scope.alumno.tipo_doc
						$scope.alumno.tipo_doc = tipo_doc








	$http.get('::paises').then((r)->
		$scope.paises = r.data
	)


	$scope.guardar = ()->
		$http.put('::alumnos/update/'+$scope.alumno.id, $scope.alumno).then((r)->
			toastr.success 'Alumno actualizado correctamente'
		, (r2)->
			toastr.error 'No se pudo guardar el alumno'
		)


	$scope.paisNacSelect = ($item, $model)->
		$http.get("::ciudades/departamentos/"+$item.id).then((r)->
			$scope.departamentosNac = r.data

			if typeof $scope.alumno.pais_doc is 'undefined'
				$scope.alumno.pais_doc = $item
				$scope.paisSelecionado($item)
		)

	$scope.departNacSelect = ($item)->
		$http.get("::ciudades/por-departamento/"+$item.departamento).then((r)->
			$scope.ciudadesNac = r.data

			if typeof $scope.alumno.departamento_doc is 'undefined'
				$scope.alumno.departamento_doc = $item
				$scope.departSeleccionado($item)
		)

	$scope.paisSelecionado = ($item, $model)->

		$http.get("::ciudades/departamentos/"+$item.id).then((r)->
			$scope.departamentos = r.data
		)

	$scope.departSeleccionado = ($item)->
		$http.get("::ciudades/por-departamento/"+$item.departamento).then((r)->
			$scope.ciudades = r.data
		)

	$scope.dateOptions =
		formatYear: 'yyyy'


	$scope.restarEstrato = ()->
		if $scope.alumno.estrato > 0
			$scope.alumno.estrato = $scope.alumno.estrato - 1
	$scope.sumarEstrato = ()->
		if $scope.alumno.estrato < 10
			$scope.alumno.estrato = parseInt($scope.alumno.estrato) + 1




	$scope.cambiarGrupo = ()->
		modalInstance = $modal.open({
			templateUrl: '==alumnos/matricularEn.tpl.html'
			controller: 'MatricularEnCtrl'
			resolve:
				alumno: ()->
					$scope.alumno
				grupos: ()->
					$scope.grupos
				year_id: ()->
					$scope.USER.year_id
		})
		modalInstance.result.then( (alum)->

			for grupo in $scope.grupos
				if grupo.id == alum.grupo_id
					$scope.alumno.grupo_nombre  = grupo.nombre
					$scope.alumno.grupo_id      = grupo.id
		)



	$scope.religionEditPressEnter = (row)->
		$scope.$broadcast(uiGridEditConstants.events.END_CELL_EDIT);


	$scope.tipoDocSeleccionado = ($item, row)->
		datos = { propiedad: 'tipo_doc', valor: $item.id }
		person = 'acudientes'

		if row.subGridOptions
			person 			= 'alumnos'
			datos.alumno_id = row.alumno_id
		else
			datos.acudiente_id 	= row.acudiente_id
			datos.parentesco_id = row.parentesco_id
			datos.user_acud_id 	= row.user_id

		$http.put('::' + person + '/guardar-valor', datos ).then((r)->
			toastr.success 'Alumno(a) actualizado con éxito', 'Actualizado'
		, (r2)->
			row.tipo_doc = oldValue
			toastr.error 'Cambio no guardado', 'Error'
		)


	$scope.matricularUno = (row, recargar)->
		if not $scope.dato.grupo.id
			toastr.warning 'Debes definir el grupo al que vas a matricular.', 'Falta grupo'
			return

		datos = { alumno_id: row.alumno_id, grupo_id: $scope.dato.grupo.id, year_id: $scope.USER.year_id }

		$http.post('::matriculas/matricularuno', datos).then((r)->
			r = r.data
			row.matricula_id 			= r.id
			row.grupo_id 				= r.grupo_id
			row.estado 					= 'MATR'
			row.fecha_matricula_ant 	= r.fecha_matricula.date
			row.fecha_matricula 		= new Date(r.fecha_matricula.date)
			toastr.success 'Alumno matriculado con éxito', 'Matriculado'
			if recargar
				$scope.traerAlumnnosConGradosAnterior()
			return row
		, (r2)->
			toastr.error 'No se pudo matricular el alumno.', 'Error'

		)

	$scope.cambiaEpsCheck = (texto)->
		$scope.verificandoEps = true
		return $http.put('::alumnos/eps-check', {texto: texto}).then((r)->
			$scope.eps_match 		= r.data.eps
			$scope.verificandoEps 	= false
			return $scope.eps_match.map((item)->
				return item.eps
			)
		)


	$scope.reMatricularUno = (row)->

		datos = { matricula_id: row.matricula_id }

		$http.put('::matriculas/re-matricularuno', datos).then((r)->
			r = r.data
			toastr.success 'Alumno rematriculado', 'Matriculado'
			return row
		, (r2)->
			toastr.error 'No se pudo matricular el alumno.', 'Error'

		)


	$scope.setAsistente = (fila)->

		$http.put('::matriculas/set-asistente', {matricula_id: fila.matricula_id, grupo_id: $scope.alumno.grupo_id}).then((r)->
			toastr.success 'Guardado como asistente'
		, (r2)->
			toastr.error 'No se pudo guardar como asistente', 'Error'
		)



	$scope.cambiarFechaRetiro = (row)->

		$http.put('::matriculas/cambiar-fecha-retiro', { matricula_id: row.matricula_id, fecha_retiro: row.fecha_retiro }).then((r)->
			toastr.success 'Fecha retiro guardada'
		, (r2)->
			row.fecha_retiro = row.fecha_retiro_ant
			toastr.error 'No se pudo guardar la fecha', 'Error'
		)


	$scope.cambiarFechaMatricula = (row)->

		$http.put('::matriculas/cambiar-fecha-matricula', { matricula_id: row.matricula_id, fecha_matricula: row.fecha_matricula }).then((r)->
			toastr.success 'Fecha matrícula guardada'
		, (r2)->
			row.fecha_matricula = row.fecha_matricula_ant
			toastr.error 'No se pudo guardar la fecha', 'Error'
		)





	$scope.desertar = (row)->
		fecha = row.fecha_retiro
		if row.fecha_retiro_ant == null
			fecha 				= new Date()
			row.fecha_retiro 	= fecha

		$http.put('::matriculas/desertar', {matricula_id: row.matricula_id, fecha_retiro: row.fecha_retiro }).then((r)->
			toastr.success 'Alumno desertado'
		, (r2)->
			toastr.error 'No se pudo desertar', 'Problema'
		)




	$scope.retirar = (row)->
		fecha = row.fecha_retiro
		if row.fecha_retiro_ant == null
			fecha 				= new Date()
			row.fecha_retiro 	= fecha

		$http.put('::matriculas/retirar', {matricula_id: row.matricula_id, fecha_retiro: row.fecha_retiro }).then((r)->
			toastr.success 'Alumno retirado'
		, (r2)->
			toastr.error 'No se pudo desmatricular', 'Problema'
		)





	$scope.cambiarPazysalvo = (fila)->
		fila.pazysalvo = !fila.pazysalvo
		if not fila.alumno_id
			fila.alumno_id = fila.id

		datos =
			alumno_id: 	fila.alumno_id
			propiedad: 	'pazysalvo'
			valor: 		fila.pazysalvo

		$http.put('::alumnos/guardar-valor', datos).then((r)->
			console.log 'Cambios guardados'
		, (r2)->
			fila.pazysalvo = !fila.pazysalvo
			toastr.error 'Cambio no guardado', 'Error'
		)


	$scope.guardarValor = (rowEntity, colDef, newValue)->

		if not rowEntity.alumno_id
			rowEntity.alumno_id = fila.id


		if colDef == "sexo"
			newValue = newValue.toUpperCase()
			if !(newValue == 'M' or newValue == 'F')
				toastr.warning 'Debe usar M o F'
				rowEntity.sexo = $scope.alum_copy['sexo']
				return

		if colDef == "fecha_matricula"
			return $scope.cambiarFechaMatricula(rowEntity)


		if colDef == "tipo_sangre"
			newValue = newValue.toUpperCase()
			if !($scope.tipos_sangre.indexOf(newValue) > -1)
				toastr.warning 'Debe usar: ' + $scope.tipos_sangre.join(' ')
				rowEntity.tipo_sangre = $scope.alum_copy['tipo_sangre']
				return


		if colDef == "estrato"
			if newValue < 0 or newValue > 9
				toastr.warning 'Valor no admitido'
				rowEntity.estrato = $scope.alum_copy['estrato']
				return


		if colDef == "documento"
			if newValue.length != 10 and newValue.length != 0
				toastr.warning 'Debe ser de diez dígitos'
				#rowEntity.documento = oldValue
				return

		$http.put('::alumnos/guardar-valor', {alumno_id: rowEntity.alumno_id, propiedad: colDef, valor: newValue } ).then((r)->
			toastr.success 'Alumno(a) actualizado con éxito'
		, (r2)->
			rowEntity[colDef] = $scope.alum_copy[colDef]
			toastr.error 'Cambio no guardado', 'Error'
		)


	return
])