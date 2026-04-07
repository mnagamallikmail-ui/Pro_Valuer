package com.bwvr.backend.security;

import com.bwvr.backend.entity.BwvrUser;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;

public class UserDetailsImpl implements UserDetails {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String username;
    private String password;
    private String role;
    private String status;
    private Collection<? extends GrantedAuthority> authorities;

    public UserDetailsImpl(Long id, String username, String password, String role, String status,
            Collection<? extends GrantedAuthority> authorities) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.role = role;
        this.status = status;
        this.authorities = authorities;
    }

    public static UserDetailsImpl build(BwvrUser user) {
        GrantedAuthority authority = new SimpleGrantedAuthority("ROLE_" + user.getRole());

        return new UserDetailsImpl(
                user.getId(),
                user.getUsername(),
                user.getPasswordHash(),
                user.getRole(),
                user.getStatus(),
                Collections.singletonList(authority));
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    public Long getId() { return id; }
    public String getRole() { return role; }
    public String getStatus() { return status; }

    @Override
    public String getPassword() { return password; }

    @Override
    public String getUsername() { return username; }

    @Override
    public boolean isAccountNonExpired() { return true; }

    @Override
    public boolean isAccountNonLocked() { return !"REJECTED".equals(status); }

    @Override
    public boolean isCredentialsNonExpired() { return true; }

    @Override
    public boolean isEnabled() { return "APPROVED".equals(status); }
}
