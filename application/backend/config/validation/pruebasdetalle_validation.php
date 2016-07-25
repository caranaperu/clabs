<?php

$config['v_pruebasdetalle'] = array(
    // Para la lectura de un contribuyente basado eb su id
    'getPruebasDetalle' => array(
        array(
            'field' => 'pruebas_detalle_id',
            'label' => 'lang:pruebas_detalle_id',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'updPruebasDetalle' => array(
        array(
            'field' => 'pruebas_detalle_id',
            'label' => 'lang:pruebas_detalle_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'pruebas_codigo',
            'label' => 'lang:pruebas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'pruebas_detalle_prueba_codigo',
            'label' => 'lang:pruebas_detalle_prueba_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'pruebas_detalle_orden',
            'label' => 'lang:pruebas_detalle_orden',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_bool|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delPruebasDetalle' => array(
        array(
            'field' => 'pruebas_detalle_id',
            'label' => 'lang:pruebas_detalle_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss'
        )
    ),
    'addPruebasDetalle' => array(
        array(
            'field' => 'pruebas_codigo',
            'label' => 'lang:pruebas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'pruebas_detalle_prueba_codigo',
            'label' => 'lang:pruebas_detalle_prueba_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'pruebas_detalle_orden',
            'label' => 'lang:pruebas_detalle_orden',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_bool|xss_clean")'
        )
    )
);
?>