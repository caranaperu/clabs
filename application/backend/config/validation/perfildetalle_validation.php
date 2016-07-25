<?php

$config['v_perfildetalle'] = array(
// Para la lectura de un contribuyente basado eb su id
    'getPerfilDetalle' => array(
        array(
            'field' => 'perfdet_id',
            'label' => 'lang:perfdet_id',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'updPerfilDetalle' => array(
        array(
            'field' => 'perfdet_id',
            'label' => 'lang:perfdet_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'perfil_id',
            'label' => 'lang:perfil_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'perfdet_accleer',
            'label' => 'lang:perfdet_accleer',
            'rules' => 'required|is_bool|xss_clean'
        ),
        array(
            'field' => 'perfdet_accagregar',
            'label' => 'lang:perfdet_accagregar',
            'rules' => 'required|is_bool|xss_clean'
        ),
        array(
            'field' => 'perfdet_accactualizar',
            'label' => 'lang:perfdet_accactualizar',
            'rules' => 'required|is_bool|xss_clean'
        ),
        array(
            'field' => 'perfdet_acceliminar',
            'label' => 'lang:perfdet_acceliminar',
            'rules' => 'required|is_bool|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delPerfilDetalle' => array(
        array(
            'field' => 'perfdet_id',
            'label' => 'lang:perfdet_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addPerfilDetalle' => array(
        array(
            'field' => 'perfil_id',
            'label' => 'lang:perfil_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'perfdet_accleer',
            'label' => 'lang:perfdet_accleer',
            'rules' => 'required|is_bool|xss_clean'
        ),
        array(
            'field' => 'perfdet_accagregar',
            'label' => 'lang:perfdet_accagregar',
            'rules' => 'required|is_bool|xss_clean'
        ),
        array(
            'field' => 'perfdet_accactualizar',
            'label' => 'lang:perfdet_accactualizar',
            'rules' => 'required|is_bool|xss_clean'
        ),
        array(
            'field' => 'perfdet_acceliminar',
            'label' => 'lang:perfdet_acceliminar',
            'rules' => 'required|is_bool|xss_clean'
        )
    )
);
?>