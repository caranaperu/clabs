<?php

$config['v_pruebastipo'] = array(
    'getPruebasTipo' => array(
        array(
            'field' => 'pruebas_tipo_codigo',
            'label' => 'lang:pruebas_tipo_codigo',
            'rules' => 'required|alpha|xss_clean||max_length[8]'
        )
    ),
    'updPruebasTipo' => array(
        array(
            'field' => 'pruebas_tipo_codigo',
            'label' => 'lang:pruebas_tipo_codigo',
            'rules' => 'required|alpha|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'pruebas_tipo_descripcion',
            'label' => 'lang:pruebas_tipo_descripcion',
            'rules' => 'required|xss_clean|max_length[120]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delPruebasTipo' => array(
        array(
            'field' => 'pruebas_tipo_codigo',
            'label' => 'lang:pruebas_tipo_codigo',
            'rules' => 'required|alpha|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addPruebasTipo' => array(
              array(
            'field' => 'pruebas_tipo_codigo',
            'label' => 'lang:pruebas_tipo_codigo',
            'rules' => 'required|alpha|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'pruebas_tipo_descripcion',
            'label' => 'lang:pruebas_tipo_descripcion',
            'rules' => 'required|xss_clean|max_length[120]'
        )
    )
);
?>