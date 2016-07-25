<?php

$config['v_apppruebas'] = array(
    'getAppPruebas' => array(
        array(
            'field' => 'apppruebas_codigo',
            'label' => 'lang:apppruebas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        )
    ),
    'updAppPruebas' => array(
        array(
            'field' => 'apppruebas_codigo',
            'label' => 'lang:apppruebas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'apppruebas_descripcion',
            'label' => 'lang:apppruebas_descripcion',
            'rules' => 'required|xss_clean|max_length[200]'
        ),
        array(
            'field' => 'pruebas_clasificacion_codigo',
            'label' => 'lang:pruebas_clasificacion_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'apppruebas_multiple',
            'label' => 'lang:pruebas_multiple',
            'rules' => 'required|is_bool|xss_clean'
        ),
        array(
            'field' => 'apppruebas_marca_menor',
            'label' => 'lang:apppruebas_marca_menor',
            'rules' => 'required|xss_clean'
        ),
        array(
            'field' => 'apppruebas_marca_mayor',
            'label' => 'lang:apppruebas_marca_mayor',
            'rules' => 'required|xss_clean'
        ),
        array(
            'field' => 'apppruebas_verifica_viento',
            'label' => 'lang:apppruebas_verifica_viento',
            'rules' => 'is_bool|xss_clean'
        ),
        array(
            'field' => 'apppruebas_viento_individual',
            'label' => 'lang:apppruebas_verifica_viento',
            'rules' => 'is_bool|xss_clean'
        ),
        array(
            'field' => 'apppruebas_viento_limite_normal',
            'label' => 'lang:apppruebas_viento_limite_normal',
            'rules' => 'decimal|xss_clean'
        ),
        array(
            'field' => 'apppruebas_viento_limite_multiple',
            'label' => 'lang:apppruebas_viento_limite_multiple',
            'rules' => 'decimal|xss_clean'
        ),
        array(
            'field' => 'apppruebas_nro_atletas',
            'label' => 'lang:apppruebas_viento_limite_multiple',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'apppruebas_factor_manual',
            'label' => 'lang:apppruebas_factor_manual',
            'rules' => 'decimal|xss_clean|greater_than[-0.01]|less_than[0.31]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delAppPruebas' => array(
        array(
            'field' => 'apppruebas_codigo',
            'label' => 'lang:apppruebas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addAppPruebas' => array(
        array(
            'field' => 'apppruebas_codigo',
            'label' => 'lang:apppruebas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'apppruebas_descripcion',
            'label' => 'lang:apppruebas_descripcion',
            'rules' => 'required|xss_clean|max_length[200]'
        ),
        array(
            'field' => 'pruebas_clasificacion_codigo',
            'label' => 'lang:pruebas_clasificacion_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'apppruebas_multiple',
            'label' => 'lang:pruebas_multiple',
            'rules' => 'required|is_bool|xss_clean'
        ),
        array(
            'field' => 'apppruebas_marca_menor',
            'label' => 'lang:apppruebas_marca_menor',
            'rules' => 'required|xss_clean'
        ),
        array(
            'field' => 'apppruebas_marca_mayor',
            'label' => 'lang:apppruebas_marca_mayor',
            'rules' => 'required|xss_clean'
        ),
        array(
            'field' => 'apppruebas_verifica_viento',
            'label' => 'lang:apppruebas_verifica_viento',
            'rules' => 'is_bool|xss_clean'
        ),
        array(
            'field' => 'apppruebas_viento_individual',
            'label' => 'lang:apppruebas_verifica_viento',
            'rules' => 'is_bool|xss_clean'
        ),
        array(
            'field' => 'apppruebas_viento_limite_normal',
            'label' => 'lang:apppruebas_viento_limite_normal',
            'rules' => 'decimal|xss_clean'
        ),
        array(
            'field' => 'apppruebas_viento_limite_multiple',
            'label' => 'lang:apppruebas_viento_limite_multiple',
            'rules' => 'decimal|xss_clean'
        ),
        array(
            'field' => 'apppruebas_nro_atletas',
            'label' => 'lang:apppruebas_viento_limite_multiple',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'apppruebas_factor_manual',
            'label' => 'lang:apppruebas_factor_manual',
            'rules' => 'decimal|xss_clean|greater_than[-0.01]|less_than[0.31]'
        )
    )
);
?>