<?php

$config['v_pruebasclasificacion'] = array(
    'getPruebasClasificacion' => array(
        array(
            'field' => 'pruebas_clasificacion_codigo',
            'label' => 'lang:pruebas_clasificacion_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[8]'
        )
    ),
    'updPruebasClasificacion' => array(
        array(
            'field' => 'pruebas_clasificacion_codigo',
            'label' => 'lang:pruebas_clasificacion_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'pruebas_clasificacion_descripcion',
            'label' => 'lang:pruebas_clasificacion_descripcion',
            'rules' => 'required|xss_clean|max_length[120]'
        ),
        array(
            'field' => 'pruebas_tipo_codigo',
            'label' => 'lang:pruebas_tipo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[5]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delPruebasClasificacion' => array(
        array(
            'field' => 'pruebas_clasificacion_codigo',
            'label' => 'lang:pruebas_clasificacion_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addPruebasClasificacion' => array(
        array(
            'field' => 'pruebas_clasificacion_codigo',
            'label' => 'lang:pruebas_clasificacion_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'pruebas_clasificacion_descripcion',
            'label' => 'lang:pruebas_clasificacion_descripcion',
            'rules' => 'required|xss_clean|max_length[120]'
        ),
        array(
            'field' => 'pruebas_tipo_codigo',
            'label' => 'lang:pruebas_tipo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[5]'
        )
    )
);
?>