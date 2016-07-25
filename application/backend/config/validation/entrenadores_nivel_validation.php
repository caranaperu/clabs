<?php

$config['v_entrenadores_nivel'] = array(
    'getEntrenadoresNivel' => array(
        array(
            'field' => 'entrenadores_nivel_codigo',
            'label' => 'lang:entrenadores_nivel_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        )
    ),
    'updEntrenadoresNivel' => array(
        array(
            'field' => 'entrenadores_nivel_codigo',
            'label' => 'lang:entrenadores_nivel_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'entrenadores_nivel_descripcion',
            'label' => 'lang:entrenadores_nivel_descripcion',
            'rules' => 'required|xss_clean|max_length[60]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delEntrenadoresNivel' => array(
        array(
            'field' => 'entrenadores_nivel_codigo',
            'label' => 'lang:entrenadores_nivel_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addEntrenadoresNivel' => array(
              array(
            'field' => 'entrenadores_nivel_codigo',
            'label' => 'lang:entrenadores_nivel_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'entrenadores_nivel_descripcion',
            'label' => 'lang:entrenadores_nivel_descripcion',
            'rules' => 'required|xss_clean|max_length[60]'
        )
    )
);
?>