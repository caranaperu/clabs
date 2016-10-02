<?php

$config['v_producto'] = array(
    'getProducto' => array(
        array(
            'field' => 'insumo_id',
            'label' => 'lang:insumo_id',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'updProducto' => array(
        array(
            'field' => 'empresa_id',
            'label' => 'lang:id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'insumo_id',
            'label' => 'lang:insumo_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'insumo_tipo',
            'label' => 'lang:insumo_tipo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[2]'
        ),
        array(
            'field' => 'insumo_codigo',
            'label' => 'lang:insumo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'insumo_descripcion',
            'label' => 'lang:insumo_descripcion',
            'rules' => 'required|xss_clean|max_length[60]'
        ),
        array(
            'field' => 'insumo_merma',
            'label' => 'lang:insumo_merma',
            'rules' => 'required|decimal|greater_than[0.00] |xss_clean'
        ),

        array(
            'field' => 'moneda_codigo_costo',
            'label' => 'lang:moneda_codigo_costo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delProducto' => array(
        array(
            'field' => 'insumo_id',
            'label' => 'lang:insumo_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addProducto' => array(
        array(
            'field' => 'empresa_id',
            'label' => 'lang:id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'insumo_tipo',
            'label' => 'lang:insumo_tipo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[2]'
        ),
        array(
            'field' => 'insumo_codigo',
            'label' => 'lang:insumo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'insumo_descripcion',
            'label' => 'lang:insumo_descripcion',
            'rules' => 'required|xss_clean|max_length[60]'
        ),
        array(
            'field' => 'unidad_medida_codigo_costo',
            'label' => 'lang:unidad_medida_codigo_costo',
            'rules' => 'required|alpha|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'insumo_merma',
            'label' => 'lang:insumo_merma',
            'rules' => 'required|decimal|greater_than[0.00] |xss_clean'
        ),
        array(
            'field' => 'moneda_codigo_costo',
            'label' => 'lang:moneda_codigo_costo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[8]'
        )
    )
);
?>