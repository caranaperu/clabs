<?php

$config['v_cotizacion'] = array(
    // Para la lectura de un contribuyente basado eb su id
    'getCotizacion' => array(
        array(
            'field' => 'cotizacion_id',
            'label' => 'lang:cotizacion_id',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'updCotizacion' => array(
        array(
            'field' => 'cotizacion_id',
            'label' => 'lang:cotizacion_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'empresa_id',
            'label' => 'lang:empresa_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'cliente_id',
            'label' => 'lang:cliente_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'cotizacion_es_cliente_real',
            'label' => 'lang:cotizacion_es_cliente_real',
            'rules' => 'is_bool|xss_clean")'
        ),
        array(
            'field' => 'moneda_codigo',
            'label' => 'lang:moneda_codigo',
            'rules' => 'required|alpha|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'cotizacion_fecha',
            'label' => 'lang:cotizacion_fecha',
            'rules' => 'required|validDate|xss_clean'
        ),
        array(
            'field' => 'cotizacion_numero',
            'label' => 'lang:cotizacion_numero',
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
    'delCotizacion' => array(
        array(
            'field' => 'cotizacion_id',
            'label' => 'lang:cotizacion_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss'
        )
    ),
    'addCotizacion' => array(
        array(
            'field' => 'empresa_id',
            'label' => 'lang:empresa_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'cliente_id',
            'label' => 'lang:cliente_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'cotizacion_es_cliente_real',
            'label' => 'lang:cotizacion_es_cliente_real',
            'rules' => 'is_bool|xss_clean")'
        ),
        array(
            'field' => 'moneda_codigo',
            'label' => 'lang:moneda_codigo',
            'rules' => 'required|alpha|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'cotizacion_fecha',
            'label' => 'lang:cotizacion_fecha',
            'rules' => 'required|validDate|xss_clean'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_bool|xss_clean")'
        )
    )
);
?>