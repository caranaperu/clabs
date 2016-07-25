<?php

$config['v_competencias'] = array(
    'getCompetencias' => array(
        array(
            'field' => 'competencias_codigo',
            'label' => 'lang:competencias_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        )
    ),
    'updCompetencias' => array(
        array(
            'field' => 'competencias_codigo',
            'label' => 'lang:competencias_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'competencias_descripcion',
            'label' => 'lang:competencias_descripcion',
            'rules' => 'required|xss_clean|max_length[200]'
        ),
        array(
            'field' => 'competencia_tipo_codigo',
            'label' => 'lang:competencia_tipo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'categorias_codigo',
            'label' => 'lang:categorias_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'paises_codigo',
            'label' => 'lang:paises_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'ciudades_codigo',
            'label' => 'lang:ciudades_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'competencias_fecha_inicio',
            'label' => 'lang:competencias_fecha_inicio',
            'rules' => 'required|validDate|xss_clean'
        ),
        array(
            'field' => 'competencias_fecha_final',
            'label' => 'lang:competencias_fecha_final',
            'rules' => 'required|validDate|xss_clean|isFutureOrSame_date[competencias_fecha_inicio]'
        ),
        array(
            'field' => 'competencias_es_oficial',
            'label' => 'lang:competencias_es_oficial',
            'rules' => 'is_bool|xss_clean'
        ),
        array(
            'field' => 'competencias_clasificacion',
            'label' => 'lang:competencias_clasificacion',
            'rules' => 'required|alpha|xss_clean|max_length[1]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delCompetencias' => array(
        array(
            'field' => 'competencias_codigo',
            'label' => 'lang:competencias_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addCompetencias' => array(
        array(
            'field' => 'competencias_codigo',
            'label' => 'lang:competencias_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'competencias_descripcion',
            'label' => 'lang:competencias_descripcion',
            'rules' => 'required|xss_clean|max_length[200]'
        ),
        array(
            'field' => 'competencia_tipo_codigo',
            'label' => 'lang:competencia_tipo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'categorias_codigo',
            'label' => 'lang:categorias_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'paises_codigo',
            'label' => 'lang:paises_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'ciudades_codigo',
            'label' => 'lang:ciudades_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'competencias_fecha_inicio',
            'label' => 'lang:competencias_fecha_inicio',
            'rules' => 'required|validDate|xss_clean'
        ),
        array(
            'field' => 'competencias_fecha_final',
            'label' => 'lang:competencias_fecha_final',
            'rules' => 'required|validDate|xss_clean|isFutureOrSame_date[competencias_fecha_inicio]'
        ),
        array(
            'field' => 'competencias_es_oficial',
            'label' => 'lang:competencias_es_oficial',
            'rules' => 'is_bool|xss_clean'
        ),
        array(
            'field' => 'competencias_clasificacion',
            'label' => 'lang:competencias_clasificacion',
            'rules' => 'required|alpha|xss_clean|max_length[1]'
        )
    )
);
?>