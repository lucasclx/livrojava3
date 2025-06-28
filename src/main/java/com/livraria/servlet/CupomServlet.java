package com.livraria.servlet;

import com.livraria.dao.CupomDAO;
import com.livraria.model.Cupom;
import com.google.gson.Gson;
import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class CupomServlet extends HttpServlet {
    private CupomDAO cupomDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        cupomDAO = new CupomDAO();
        gson = new Gson();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        if (action == null) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("erro", "Ação não especificada");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write(gson.toJson(errorResponse));
            return;
        }

        try {
            switch (action) {
                case "validar":
                    validarCupom(request, response);
                    break;
                default:
                    Map<String, String> errorResponse = new HashMap<>();
                    errorResponse.put("erro", "Ação não reconhecida");
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write(gson.toJson(errorResponse));
            }
        } catch (SQLException e) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("erro", "Erro no banco de dados: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(gson.toJson(errorResponse));
        }
    }
    
    private void validarCupom(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        String codigo = request.getParameter("codigo");
        Map<String, Object> result = new HashMap<>();

        if (codigo == null || codigo.trim().isEmpty()) {
            result.put("valido", false);
            result.put("mensagem", "Código do cupom é obrigatório");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        Cupom cupom = cupomDAO.validarCupom(codigo.trim());

        if (cupom != null) {
            result.put("valido", true);
            result.put("mensagem", "Cupom válido!");
            result.put("cupom", cupom);
        } else {
            result.put("valido", false);
            result.put("mensagem", "Cupom inválido ou expirado");
        }
        response.getWriter().write(gson.toJson(result));
    }
}