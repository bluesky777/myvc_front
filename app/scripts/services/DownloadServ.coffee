angular.module('myvcFrontApp')

.factory('DownloadServ', ['$http', '$q', ($http, $q) ->
	res = {}

	res.download = (url, defaultFileName)->

		deferred  = $q.defer()
		$http.get(url, { responseType: "blob" }).then( (data)->
				type          = data.headers('Content-Type');
				disposition   = data.headers('Content-Disposition');
				if (disposition)
						match = disposition.match(/.*filename=\"?([^;\"]+)\"?.*/);
						if (match[1])
								defaultFileName = match[1];

				defaultFileName = defaultFileName.replace(/[<>:"\/\\|?*]+/g, '_')
				blob = new Blob([data.data], { type: type });
				window.saveAs(blob, defaultFileName);
				deferred.resolve(defaultFileName);
		, (r2)->
				console.log r2
				deferred.reject(r2);
		);
		return deferred.promise



	res.download2 = (url, defaultFileName)->

		deferred  = $q.defer()
		$http.get(url, { responseType: 'arraybuffer' })
			.then((response)->
				file = new Blob([response], { type: "Type:application/vnd.ms-excel; charset=UTF-8" })
				fileURL = URL.createObjectURL(file);
				window.open(fileURL);
				deferred.resolve(defaultFileName);
			, (r2)->
				console.log 'Pailaaassss', r2
				deferred.reject(r2);
			);
		return deferred.promise

	return res

])
