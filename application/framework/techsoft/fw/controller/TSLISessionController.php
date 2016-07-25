<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Interfase base para controladores que manejen requerimientos de
 * session.
 *
 * @author $Author: aranape $
 * @since 17-May-2012
 * @version $Id: TSLISessionController.php 4 2014-02-11 03:31:42Z aranape $
 *
 * $Date: 2014-02-10 22:31:42 -0500 (lun, 10 feb 2014) $
 * $Rev: 4 $
 */
interface TSLISessionController  {


    /**
     * Metodo hook que se usara para determinar el usuario conectado a la session
     *
     * @return string con el nombre del usuario conectado a la session
     *
     */
    public function getUser();
}
?>


