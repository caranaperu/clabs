<?php

$config['v_unidadmedida'] = array(
    'getUnidadMedida' => array(
        array(
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha|xss_clean||max_length[8]'
        )
    ),
    'updUnidadMedida' => array(
        array(
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'unidad_medida_descripcion',
            'label' => 'lang:unidad_medida_descripcion',
            'rules' => 'required|xss_clean|max_length[80]'
        ),
        array(
            'field' => 'unidad_medida_siglas',
            'label' => 'lang:unidad_medida_siglas',
            'rules' => 'required|xss_clean|max_length[6]'
        ),
        array(
            'field' => 'unidad_medida_tipo',
            'label' => 'lang:unidad_medida_tipo',
            'rules' => 'required|xss_clean|max_length[1]'
        ),
        array(
            'field' => 'unidad_medida_protected',
            'label' => 'lang:unidad_medida_protected',
            'rules' => 'required|is_bool|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delUnidadMedida' => array(
        array(
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addUnidadMedida' => array(
        array(
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'unidad_medida_descripcion',
            'label' => 'lang:unidad_medida_descripcion',
            'rules' => 'required|xss_clean|max_length[80]'
        ),
        array(
            'field' => 'unidad_medida_siglas',
            'label' => 'lang:unidad_medida_siglas',
            'rules' => 'required|xss_clean|max_length[6]'
        ),
        array(
            'field' => 'unidad_medida_tipo',
            'label' => 'lang:unidad_medida_tipo',
            'rules' => 'required|xss_clean|max_length[1]'
        ),
        array(
            'field' => 'unidad_medida_protected',
            'label' => 'lang:unidad_medida_protected',
            'rules' => 'required|is_bool|xss_clean'
        )
    )
);
?>