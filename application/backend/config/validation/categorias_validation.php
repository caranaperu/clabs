<?php

$config['v_categorias'] = array(
    'getCategorias' => array(
        array(
            'field' => 'categorias_codigo',
            'label' => 'lang:categorias_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        )
    ),
    'updCategorias' => array(
        array(
            'field' => 'categorias_codigo',
            'label' => 'lang:categorias_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'categorias_descripcion',
            'label' => 'lang:categorias_descripcion',
            'rules' => 'required|xss_clean|max_length[120]'
        ),
        array(
            'field' => 'categorias_edad_inicial',
            'label' => 'lang:categorias_edad_inicial',
            'rules' => 'required|integer|xss_clean|less_than_field[categorias_edad_final]'
        ),
        array(
            'field' => 'categorias_edad_final',
            'label' => 'lang:categorias_edad_final',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'categorias_valido_desde',
            'label' => 'lang:categorias_valido_desde',
            'rules' => 'validDate|xss_clean'
        ),
        array(
            'field' => 'categorias_validacion',
            'label' => 'lang:categorias_validacion',
            'rules' => 'required|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delCategorias' => array(
        array(
            'field' => 'categorias_codigo',
            'label' => 'lang:categorias_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addCategorias' => array(
        array(
            'field' => 'categorias_codigo',
            'label' => 'lang:categorias_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'categorias_descripcion',
            'label' => 'lang:categorias_descripcion',
            'rules' => 'required|xss_clean|max_length[120]'
        ),
        array(
            'field' => 'categorias_edad_inicial',
            'label' => 'lang:categorias_edad_inicial',
            'rules' => 'required|categorias_edad_inicial|xss_clean'
        ),
        array(
            'field' => 'categorias_edad_final',
            'label' => 'lang:categorias_edad_final',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'categorias_valido_desde',
            'label' => 'lang:categorias_valido_desde',
            'rules' => 'validDate|xss_clean'
        ),
        array(
            'field' => 'categorias_validacion',
            'label' => 'lang:categorias_validacion',
            'rules' => 'required|xss_clean'
        )
    )
);
?>