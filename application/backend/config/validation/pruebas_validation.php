<?php

$config['v_pruebas'] = array(
    'getPruebas' => array(
        array(
            'field' => 'pruebas_codigo',
            'label' => 'lang:pruebas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        )
    ),
    'updPruebas' => array(
        array(
            'field' => 'pruebas_codigo',
            'label' => 'lang:pruebas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'pruebas_descripcion',
            'label' => 'lang:pruebas_descripcion',
            'rules' => 'required|xss_clean|max_length[150]'
        ),
        array(
            'field' => 'pruebas_generica_codigo',
            'label' => 'lang:pruebas_generica_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'categorias_codigo',
            'label' => 'lang:categorias_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'pruebas_sexo',
            'label' => 'lang:pruebas_sexo',
            'rules' => 'required|alpha|xss_clean|max_length[1]'
        ),
        array(
            'field' => 'pruebas_record_hasta',
            'label' => 'lang:pruebas_record_hasta',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'pruebas_anotaciones',
            'label' => 'lang:pruebas_anotaciones',
            'rules' => 'xss_clean|max_length[180]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delPruebas' => array(
        array(
            'field' => 'pruebas_codigo',
            'label' => 'lang:pruebas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addPruebas' => array(
        array(
            'field' => 'pruebas_codigo',
            'label' => 'lang:pruebas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'pruebas_descripcion',
            'label' => 'lang:pruebas_descripcion',
            'rules' => 'required|xss_clean|max_length[150]'
        ),
        array(
            'field' => 'pruebas_generica_codigo',
            'label' => 'lang:pruebas_generica_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'categorias_codigo',
            'label' => 'lang:categorias_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'pruebas_sexo',
            'label' => 'lang:pruebas_sexo',
            'rules' => 'required|alpha|xss_clean|max_length[1]'
        ),
        array(
            'field' => 'pruebas_record_hasta',
            'label' => 'lang:pruebas_record_hasta',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'pruebas_anotaciones',
            'label' => 'lang:pruebas_anotaciones',
            'rules' => 'xss_clean|max_length[180]'
        )
    )
);
?>