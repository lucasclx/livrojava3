package com.livraria.servlet;

import com.livraria.dao.ListaDesejosDAO;
import com.google.gson.Gson;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class ListaDesejosServlet extends HttpServlet {
    private ListaDesejosDAO listaDesejosDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        listaDesejosDAO = new ListaDesejosDAO();
        gson = new Gson();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Integer usuarioId = (Integer) session.getAttribute("usuarioId");

        if (usuarioId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"erro\":\"Usuário não autenticado\"}");
            return;
        }

        try {
            Map<String, Object> payload = gson.fromJson(request.getReader(), Map.class);
            String action = (String) payload.get("action");
            int livroId = ((Double) payload.get("livroId")).intValue();

            boolean sucesso = false;
            if ("adicionar".equals(action)) {
                sucesso = listaDesejosDAO.adicionar(usuarioId, livroId);
            } else if ("remover".equals(action)) {
                sucesso = listaDesejosDAO.remover(usuarioId, livroId);
            }

            if (sucesso) {
                response.getWriter().write("{\"sucesso\":true}");
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"erro\":\"Ação inválida\"}");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"erro\":\"" + e.getMessage() + "\"}");
        }
    }
}