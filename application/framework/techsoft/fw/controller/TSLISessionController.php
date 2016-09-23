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
     * debe retornar null si no hay ninguno conectado.
     *
     * @return string con el codigo del usuario conectado a la session
     *
     */
    public function getUserCode();

    /**
     * Retorna el id del usuario logeado , debe ser -1
     * si no existe ninguno.
     *
     * @return integer con el id del usuario logeado
     */
    public function getUserId();

    /**
     * Retorna si el usuariop esta conectado al sistema.
     *
     * @return boolean true si el usuario esta logeado al sistema.
     */
    public function isLoggedIn();

    /**
     * Retorna el valor de un dato de sesion en base a una llave.
     *
     * @param string $name con el nombre llave del dato a buscar en la sesion.
     *
     * @return mixed  retorna el datro guardado en la sesion
     */
    public function getSessionData($name);

    /**
     * Setea el codigo del usuario logeado , este valor tendra sentido
     * ser seteado si isLoggedIn esta seteado.
     *
     * @param $userCode string con el codigo del usuario a logearse.
     */
    public function setUserCode($userCode);

    /**
     * Setea el id del usuario logeado , este valor tendra sentido
     * ser seteado si isLoggedIn esta seteado.
     *
     * @param $userId integer con el id del usario logeado.
     *
     */
    public function setUserId($userId);

    /**
     * Setea si el usuario esta logeado o no al sistema.
     *
     * @param $isLoggedIn boolean true si el usuario esta logeado.
     *
     */
    public function setLoggedIn($isLoggedIn);

    /**
     * Guarda un valor en la sesion.
     *
     * @param $name string con la llave del dato a agregar a la sesion.
     * @param $data mixed el valor a guardar en la sesion
     */
    public function setSessionData($name,$data);

    /**
     * Remueve un valor en la sesion.
     *
     * @param $name string con la llave del dato a remover a la sesion.
     */
    public function unsetSessionData($name);

}
?>


