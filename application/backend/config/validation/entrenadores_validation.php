<?php

$config['v_entrenadores'] = array(
// Para la lectura de un contribuyente basado eb su id
    'getEntrenadores' => array(
        array(
            'field' => 'entrenadores_codigo',
            'label' => 'lang:entrenadores_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        )
    ),
    'updEntrenadores' => array(
        array(
            'field' => 'entrenadores_codigo',
            'label' => 'lang:entrenadores_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'entrenadores_ap_paterno',
            'label' => 'lang:entrenadores_ap_paterno',
            'rules' => 'required|onlyValidText|xss_clean|max_length[60]'
        ),
        array(
            'field' => 'entrenadores_ap_materno',
            'label' => 'lang:entrenadores_ap_materno',
            'rules' => 'required|onlyValidText|xss_clean|max_length[60]'
        ),
        array(
            'field' => 'entrenadores_nombres',
            'label' => 'lang:entrenadores_nombres',
            'rules' => 'required|onlyValidText|xss_clean|max_length[120]'
        ),
        array(
            'field' => 'entrenadores_nivel_codigo',
            'label' => 'lang:entrenadores_nivel_codigo',
            'rules' => 'required|onlyValidText|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delEntrenadores' => array(
        array(
            'field' => 'entrenadores_codigo',
            'label' => 'lang:entrenadores_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addEntrenadores' => array(
        array(
            'field' => 'entrenadores_codigo',
            'label' => 'lang:entrenadores_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'entrenadores_ap_paterno',
            'label' => 'lang:entrenadores_ap_paterno',
            'rules' => 'required|onlyValidText|xss_clean|max_length[60]'
        ),
        array(
            'field' => 'entrenadores_ap_materno',
            'label' => 'lang:entrenadores_ap_materno',
            'rules' => 'required|onlyValidText|xss_clean|max_length[60]'
        ),
        array(
            'field' => 'entrenadores_nombres',
            'label' => 'lang:entrenadores_nombres',
            'rules' => 'required|onlyValidText|xss_clean|max_length[120]'
        ),
        array(
            'field' => 'entrenadores_nivel_codigo',
            'label' => 'lang:entrenadores_nivel_codigo',
            'rules' => 'required|onlyValidText|xss_clean||max_length[15]'
        )
    )
);
?>