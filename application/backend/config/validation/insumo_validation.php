<?php

$config['v_insumo'] = array(
    'getInsumo' => array(
        array(
            'field' => 'insumo_codigo',
            'label' => 'lang:insumo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        )
    ),
    'updInsumo' => array(
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
            'field' => 'tcostos_codigo',
            'label' => 'lang:tcostos_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[5]'
        ),
        array(
            'field' => 'tinsumo_codigo',
            'label' => 'lang:tinsumo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'insumo_merma',
            'label' => 'lang:insumo_merma',
            'rules' => 'required|decimal|greater_than[0.00] |xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delInsumo' => array(
        array(
            'field' => 'insumo_codigo',
            'label' => 'lang:insumo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addInsumo' => array(
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
            'field' => 'tcostos_codigo',
            'label' => 'lang:tcostos_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[5]'
        ),
        array(
            'field' => 'tinsumo_codigo',
            'label' => 'lang:tinsumo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'insumo_merma',
            'label' => 'lang:insumo_merma',
            'rules' => 'required|decimal|greater_than[0.00] |xss_clean'
        )
    )
);
?>