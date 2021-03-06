angular.module('myvcFrontApp')
.controller('UserConfiguracionCtrl', ['$scope', '$http', '$state', 'toastr', 'AuthService', 'Perfil', 'App', 'perfilactual', ($scope, $http, $state, toastr, AuthService, Perfil, App, perfilactual) ->

	AuthService.verificar_acceso()

	$scope.data = {} # Para el popup del Datapicker
	$scope.comprobando = false
	$scope.mostrarErrorUsername = false
	$scope.mostrarErrorPassword = false
	$scope.canSaveUsername = false
	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm
	$scope.perfilPath = App.images+'perfil/'

	$scope.perfilactual  = perfilactual

	$scope.newusername = ''
	$scope.passantiguo = ''
	$scope.newpass = ''
	$scope.newpassverif = ''
	$scope.status = { passCambiado: false } # Para cerrar tab cuando se cambie el password

	$scope.nombresdeusuario = []

	$http.get('::perfiles/usernames').then((r)->
		$scope.nombresdeusuario = r.data
	, (r2)->
		toastr.error 'No se trajeron los nombres de usuario'
	)

	$scope.dateOptions =
		formatYear: 'yyyy'
		allowInvalid: true


	$scope.guardarEmailRestore = (email_rest)->
		$http.put('::perfiles/guardar-mi-email-restore', {email_restore: email_rest}).then((r)->
			toastr.success 'Email guardado con éxito'
		, (r2)->
			toastr.error 'No se trajeron los nombres de usuario'
		)


	$scope.$watch 'newusername', (oldv, newv)->
		#console.log 'oldv, newv', oldv, newv

	$scope.comprobarusername = (newusername)->

		$scope.canSaveUsername = false
		$scope.comprobando = true

		if newusername.username
			newusername = newusername.username
		if newusername == $scope.perfilactual.username
			toastr.warning 'Copia un nombre de usuario diferente al que ya tienes'
			$scope.comprobando = false
			return
		if newusername == ''
			toastr.warning 'Debes copiar un nombre de usuario.'
			$scope.comprobando = false
			return

		$http.get('::perfiles/comprobarusername/'+newusername).then((r)->
			r = r.data
			if r[0].existe
				toastr.warning 'Nombre de usuario ya en uso.'
				$scope.mostrarErrorUsername = true
			else
				$scope.mostrarErrorUsername = false
				$scope.canSaveUsername = true
			$scope.comprobando = false
		, (r2)->
			toastr.error 'No se trajeron los nombres de usuario'
			$scope.comprobando = false
		)

	$scope.guardar = ()->
		$scope.canSaveUsername = false

		datos =
			nombres:	$scope.perfilactual.nombres
			apellidos:	$scope.perfilactual.apellidos
			sexo:		$scope.perfilactual.sexo
			fecha_nac:	$scope.perfilactual.fecha_nac
			celular:	$scope.perfilactual.celular
			tipo:		$scope.perfilactual.tipo
			email_persona:	$scope.perfilactual.email_persona

		$http.put('::perfiles/update/'+$scope.perfilactual.persona_id, datos).then((r)->
			toastr.success 'Datos guardados'
		, (r2)->
			toastr.error 'Datos NO guardados', 'Problema'
			$scope.canSaveUsername = true
		)


	$scope.solicitarCambios = ()->
		$scope.canSaveUsername = false

		$http.put('::ChangesAsked/solicitar-cambios', $scope.perfilactual).then((r)->
			toastr.info 'Debes esperar que un administrador acepte cambios', 'Solicitud realizada', {timeOut: 8000}
		, (r2)->
			toastr.error 'Datos NO guardados', 'Problema'
			$scope.canSaveUsername = true
		)

	$scope.CambiarUsername = (newusername)->

		$http.put('::perfiles/guardar-username/'+$scope.perfilactual.user_id, {'username':newusername}).then((r)->
			toastr.success 'Nombre de usuario guardado'
			Perfil.User().username = newusername
			$scope.$emit 'cambianImgs', {username: newusername}
		, (r2)->
			toastr.error 'Nombre de usuario NO guardado', 'Problema'
		)

	$scope.CambiarPass = (newpass, newpassverif, passantiguo)->

		if newpass not in [newpassverif]
			toastr.warning 'Las contraseñas no coinciden'
			return
		if newpass.length < 4
			toastr.warning 'La contraseña debe tener mínimo 4 caracteres. Sin espacios ni Ñ ni tildes.'
			return

		$scope.cambiandoPass = true # Bloqueamos el botón temporalmente

		datos = {'password':newpassverif, 'oldpassword': passantiguo }


		$http.put('::perfiles/cambiarpassword/'+$scope.perfilactual.user_id, datos).then((r)->
			toastr.success 'Contraseña cambiada.'
			$scope.status.passCambiado = false
			$scope.cambiandoPass = false
		, (r2)->
			r2 = r2.data
			if r2.$error

				if r2.error.message == 'Contraseña antigua es incorrecta'
					toastr.warning r2.error.message
				else
					toastr.error 'No se pudo cambiar la contraseña.'
			else
				toastr.error 'No se pudo cambiar la contraseña.'

			$scope.cambiandoPass = false
		)

	$scope.CambiarCorreoRestore = ()->

		datos = { 'email_restore': $scope.email_restore }

		$http.put('::perfiles/cambiaremailrestore/'+$scope.perfilactual.user_id, datos).then((r)->
			toastr.success 'Contraseña cambiada.'
		, (r2)->
			toastr.error 'No se pudo cambiar la contraseña', 'Problema'
		)

])

