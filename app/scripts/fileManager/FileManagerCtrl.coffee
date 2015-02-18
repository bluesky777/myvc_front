'use strict'

angular.module("myvcFrontApp")

.controller('FileManagerCtrl', ['$scope', '$upload', '$timeout', '$filter', 'App', 'RImages', 'Restangular', 'Perfil', '$modal', 'resolved_user', ($scope, $upload, $timeout, $filter, App, RImages, Restangular, Perfil, $modal, resolved_user)->
	
	$scope.USER = resolved_user

	fixDato = ()->
		$scope.dato = 
			imgUsuario:
				id:		$scope.USER.imagen_id
				nombre:	$scope.USER.imagen_nombre 
			imgOficial:
				id:		$scope.USER.foto_id
				nombre:	$scope.USER.foto_nombre 

	fixDato()

	$scope.perfilPath = App.images + 'perfil/'
	$scope.imgFiles = []
	$scope.errorMsg = ''
	$scope.fileReaderSupported = window.FileReader != null && (window.FileAPI == null || FileAPI.html5 != false);


	RImages.getList().then((r)->
		$scope.imagenes = r
	, (r2)->
		console.log 'No se trajeron las imágenes.', r2
	)

	$scope.upload =  (files)->
		$scope.imgFiles = files
		$scope.errorMsg = ''
		console.log 'Entra al upload', files

		if files and files.length

			for i in [0...files.length]
				file = files[i]
				console.log 'file: ', file

				generateThumbAndUpload file


	generateThumbAndUpload = (file)->
		$scope.errorMsg = null
		$scope.generateThumb(file)
		uploadUsing$upload(file)

	$scope.generateThumb = (file)->
		if file != null
			if $scope.fileReaderSupported and file.type.indexOf('image') > -1
				$timeout ()->
					fileReader = new FileReader()
					fileReader.readAsDataURL(file)
					fileReader.onload = (e)->
						$timeout(()->
							file.dataUrl = e.target.result
						)
	
	uploadUsing$upload = (file)->

		if file.size > 10000000
			$scope.errorMsg = 'Archivo excede los 10MB permitidos.'
			return

		$upload.upload({
			url: App.Server + '/myimages/store',
			#fields: {'username': $scope.username},
			file: file
		}).progress( (evt)->
			progressPercentage = parseInt(100.0 * evt.loaded / evt.total)
			file.porcentaje = progressPercentage
			console.log('progress: ' + progressPercentage + '% ' + evt.config.file.name, evt.config)
		).success( (data, status, headers, config)->
			$scope.imagenes.push data.config
			console.log('Success file ' + config.file + '   -uploaded: ', data, status)
		).error((r2)->
			console.log 'Falla uploading: ', r2
		).xhr((xhr)->
			#xhr.upload.addEventListener()
			#/* return $http promise then(). Note that this promise does NOT have progress/abort/xhr functions */
		)#.then((), error, progress)


	$scope.pedirCambioUsuario = (imgUsu)->
		Restangular.one('myimages/cambiarimagenperfil', $scope.USER.user_id).put({imagen_id: imgUsu.id}).then((r)->

			Perfil.setImagen(r.imagen_id, imgUsu.nombre)
			$scope.$emit 'cambianImgs', {image: r}
		, (r2)->
			console.log 'NO Se pedirCambioUsuario: ', r2
		)

	$scope.pedirCambioOficial = (imgOfi)->
		Restangular.one('myimages/cambiarimagenoficial', $scope.USER.user_id).put({foto_id: imgOfi.id}).then((r)->

			Perfil.setOficial(r.foto_id, imgOfi.nombre)
			$scope.$emit 'cambianImgs', {foto: r}
		, (r2)->
			console.log 'NO Se pedirCambioOficial: ', r2
		)

	$scope.imagenSelect = (item, model)->
		console.log 'imagenSelect: ', item, model

	$scope.borrarImagen = (imagen)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'fileManager/removeImage.tpl.html'
			controller: 'RemoveImageCtrl'
			size: 'sm',
			resolve: 
				imagen: ()->
					imagen
		})
		modalInstance.result.then( (imag)->
			$scope.imagenes = $filter('filter')($scope.imagenes, {id: '!'+imag.id})
			console.log 'Resultado del modal: ', imag
		)

	return
])